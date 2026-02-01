import Foundation
import Testing
@testable import SlackKit

// MARK: - SlackWebhookClientTests

@Suite("SlackWebhookClient Tests")
struct SlackWebhookClientTests {

    @Test("Send simple text message successfully")
    func sendSimpleTextMessage() async throws {
        // Arrange
        let webhookURL = URL(string: "https://hooks.slack.com/services/T/B/C")!
        let mockClient = MockNetworkClient()
        let slackClient = SlackWebhookClient(webhookURL: webhookURL, networkClient: mockClient)

        // Mock a successful response
        let responseData = #"{"ok": true}"#.data(using: .utf8)!
        await mockClient.addResponse(statusCode: 200, data: responseData)

        // Act
        let message = Message(text: "Hello, Slack!")
        let response = try await slackClient.send(message)

        // Assert
        #expect(response.ok == true)
        let requests = await mockClient.requests
        #expect(requests.count == 1)

        // Verify the request body contains the text
        let requestBody = try JSONDecoder().decode([String: String].self, from: requests[0].body)
        #expect(requestBody["text"] == "Hello, Slack!")
    }

    @Test("Send message with blocks")
    func sendMessageWithBlocks() async throws {
        // Arrange
        let webhookURL = URL(string: "https://hooks.slack.com/services/T/B/C")!
        let mockClient = MockNetworkClient()
        let slackClient = SlackWebhookClient(webhookURL: webhookURL, networkClient: mockClient)

        // Mock a successful response
        let responseData = #"{"ok": true}"#.data(using: .utf8)!
        await mockClient.addResponse(statusCode: 200, data: responseData)

        // Act
        let message = Message(
            blocks: [
                HeaderBlock(text: "Header"),
                DividerBlock(),
                SectionBlock(text: .markdown("Some *markdown* text"))
            ],
            username: "Test Bot",
            iconEmoji: ":robot_face:"
        )
        let response = try await slackClient.send(message)

        // Assert
        #expect(response.ok == true)
        let requests = await mockClient.requests
        #expect(requests.count == 1)
    }

    @Test("Handle API error response")
    func handleAPIErrorResponse() async throws {
        // Arrange
        let webhookURL = URL(string: "https://hooks.slack.com/services/T/B/C")!
        let mockClient = MockNetworkClient()
        let slackClient = SlackWebhookClient(webhookURL: webhookURL, networkClient: mockClient)

        // Mock an error response
        let responseData = #"{"ok": false, "error": "invalid_webhook"}"#.data(using: .utf8)!
        await mockClient.addResponse(statusCode: 200, data: responseData)

        // Act & Assert
        let message = Message(text: "Test")
        await #expect(throws: SlackError.self) {
            try await slackClient.send(message)
        }
    }

    @Test("Handle HTTP error status")
    func handleHTTPErrorStatus() async throws {
        // Arrange
        let webhookURL = URL(string: "https://hooks.slack.com/services/T/B/C")!
        let mockClient = MockNetworkClient()
        let slackClient = SlackWebhookClient(webhookURL: webhookURL, networkClient: mockClient)

        // Mock a 404 response
        let responseData = #"Not Found"#.data(using: .utf8)!
        await mockClient.addResponse(statusCode: 404, data: responseData)

        // Act & Assert
        let message = Message(text: "Test")
        await #expect(throws: SlackError.self) {
            try await slackClient.send(message)
        }
    }

    @Test("Handle network error")
    func handleNetworkError() async throws {
        // Arrange
        let webhookURL = URL(string: "https://hooks.slack.com/services/T/B/C")!
        let mockClient = MockNetworkClient()
        let slackClient = SlackWebhookClient(webhookURL: webhookURL, networkClient: mockClient)

        // Mock a network error
        let networkError = NSError(domain: "NSURLErrorDomain", code: -1004, userInfo: nil)
        await mockClient.addError(networkError)

        // Act & Assert
        let message = Message(text: "Test")
        await #expect(throws: SlackError.self) {
            try await slackClient.send(message)
        }
    }

    @Test("Send message with attachments")
    func sendMessageWithAttachments() async throws {
        // Arrange
        let webhookURL = URL(string: "https://hooks.slack.com/services/T/B/C")!
        let mockClient = MockNetworkClient()
        let slackClient = SlackWebhookClient(webhookURL: webhookURL, networkClient: mockClient)

        // Mock a successful response
        let responseData = #"{"ok": true}"#.data(using: .utf8)!
        await mockClient.addResponse(statusCode: 200, data: responseData)

        // Act
        let message = Message(
            text: "Deployment complete",
            attachments: [
                Attachment(
                    color: "good",
                    title: "Build Details",
                    text: "Build #123 succeeded",
                    fields: [
                        AttachmentField(title: "Duration", value: "5m 32s"),
                        AttachmentField(title: "Environment", value: "Production")
                    ]
                )
            ]
        )
        let response = try await slackClient.send(message)

        // Assert
        #expect(response.ok == true)
        let requests = await mockClient.requests
        #expect(requests.count == 1)
    }

    @Test("Initialize with URL string")
    func initializeWithURLString() async throws {
        // Arrange & Act
        let webhookURLString = "https://hooks.slack.com/services/T/B/C"
        let slackClient = try SlackWebhookClient.create(webhookURLString: webhookURLString)

        // Assert - client was created successfully (no error thrown)
        #expect(true)  // If we got here, initialization succeeded
    }

    @Test("Throw error for invalid URL string")
    func throwErrorForInvalidURLString() async throws {
        // Arrange & Act & Assert
        let invalidURL = "not a valid url"
        #expect(throws: SlackError.self) {
            try SlackWebhookClient.create(webhookURLString: invalidURL)
        }
    }
}
