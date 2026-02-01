import Foundation

// MARK: - SlackResponse

/// A response from the Slack webhook API
public struct SlackResponse: Codable, Sendable {
    /// Whether the request was successful
    public let ok: Bool

    /// An optional error message (present when ok is false)
    public let error: String?

    /// An optional warning message
    public let warning: String?

    /// The response metadata (present for threaded messages)
    public let responseMetadata: ResponseMetadata?

    public init(
        ok: Bool,
        error: String? = nil,
        warning: String? = nil,
        responseMetadata: ResponseMetadata? = nil
    ) {
        self.ok = ok
        self.error = error
        self.warning = warning
        self.responseMetadata = responseMetadata
    }

    enum CodingKeys: String, CodingKey {
        case ok, error, warning
        case responseMetadata = "response_metadata"
    }
}

// MARK: - ResponseMetadata

/// Metadata included in threaded message responses
public struct ResponseMetadata: Codable, Sendable {
    /// An array of message timestamps
    public let messages: [String]?

    public init(messages: [String]? = nil) {
        self.messages = messages
    }
}

// MARK: - SlackWebhookClient

/// A client for sending messages to Slack via Incoming Webhooks
public final actor SlackWebhookClient {
    private let webhookURL: URL
    private let networkClient: any NetworkClient
    private let encoder: JSONEncoder

    /// Initializes a new Slack webhook client
    /// - Parameters:
    ///   - webhookURL: The webhook URL
    ///   - networkClient: An optional custom network client (uses URLSession by default)
    ///   - encoder: An optional custom JSON encoder
    public init(
        webhookURL: URL,
        networkClient: (any NetworkClient)? = nil,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.webhookURL = webhookURL
        self.networkClient = networkClient ?? URLSessionNetworkClient()
        self.encoder = encoder
    }

    /// Sends a message to the Slack webhook
    /// - Parameter message: The message to send
    /// - Returns: The response from Slack
    /// - Throws: A `SlackError` if the message fails to send
    @discardableResult
    public func send(_ message: Message) async throws -> SlackResponse {
        // Encode the message
        let body: Data
        do {
            body = try encoder.encode(message)
        } catch {
            throw SlackError.encodingError(error)
        }

        // Send the request
        let response = try await networkClient.post(url: webhookURL, body: body)

        // Check for HTTP errors
        guard response.isSuccess else {
            let bodyString = String(data: response.data, encoding: .utf8)
            throw SlackError.invalidResponse(statusCode: response.statusCode, body: bodyString)
        }

        // Check for rate limiting
        if response.statusCode == 429 {
            if let retryAfter = extractRetryAfter(from: response) {
                throw SlackError.rateLimitExceeded(retryAfter: retryAfter)
            }
        }

        // Decode the response
        // Slack webhooks return "ok" as plain text on success
        if let bodyString = String(data: response.data, encoding: .utf8),
           bodyString == "ok" {
            return SlackResponse(ok: true)
        }

        // Try to decode as JSON error response
        do {
            let slackResponse = try decoder.decode(SlackResponse.self, from: response.data)

            if !slackResponse.ok {
                throw SlackError.invalidMessage(slackResponse.error ?? "Unknown error")
            }

            return slackResponse
        } catch {
            throw SlackError.networkError(error)
        }
    }

    // MARK: - Private Helpers

    private var decoder: JSONDecoder {
        JSONDecoder()
    }

    private func extractRetryAfter(from response: HTTPResponse) -> Int? {
        // Try to parse rate limit info from response body
        if let body = String(data: response.data, encoding: .utf8),
           body.contains("rate_limited") {
            return 60 // Default retry after
        }
        return nil
    }
}

// MARK: - Factory Methods

extension SlackWebhookClient {
    /// Creates a new Slack webhook client with a URL string
    /// - Parameter webhookURLString: The webhook URL as a string
    /// - Returns: A new Slack webhook client
    /// - Throws: A `SlackError` if the URL string is invalid
    public static func create(webhookURLString: String) throws -> SlackWebhookClient {
        guard let url = URL(string: webhookURLString) else {
            throw SlackError.invalidURL(webhookURLString)
        }

        // Validate that the URL has a valid scheme and is properly formed
        guard url.scheme == "http" || url.scheme == "https" else {
            throw SlackError.invalidURL(webhookURLString)
        }

        return SlackWebhookClient(webhookURL: url)
    }
}
