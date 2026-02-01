import Foundation

/// Errors that can occur when interacting with the Slack Webhook API
public enum SlackError: Error, Sendable {
    /// The provided URL string is invalid
    case invalidURL(String)

    /// A network error occurred while making the request
    case networkError(Error)

    /// The server returned an invalid response
    case invalidResponse(statusCode: Int, body: String?)

    /// The rate limit has been exceeded
    case rateLimitExceeded(retryAfter: Int)

    /// An error occurred while encoding the message
    case encodingError(Error)

    /// The message payload is invalid
    case invalidMessage(String)

    /// The webhook URL is not set
    case webhookURLNotSet
}

// MARK: - CustomStringConvertible

extension SlackError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let statusCode, let body):
            if let body = body {
                return "Invalid response (status \(statusCode)): \(body)"
            } else {
                return "Invalid response (status \(statusCode))"
            }
        case .rateLimitExceeded(let retryAfter):
            return "Rate limit exceeded. Retry after \(retryAfter) seconds"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .invalidMessage(let reason):
            return "Invalid message: \(reason)"
        case .webhookURLNotSet:
            return "Webhook URL is not set"
        }
    }
}

// MARK: - LocalizedError

extension SlackError: LocalizedError {
    public var errorDescription: String? {
        description
    }
}
