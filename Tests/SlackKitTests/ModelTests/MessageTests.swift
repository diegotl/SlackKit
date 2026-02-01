import Foundation
import Testing
@testable import SlackKit

// MARK: - MessageTests

@Suite("Message Model Tests")
struct MessageTests {

    @Test("Encode simple text message")
    func encodeSimpleTextMessage() throws {
        // Arrange
        let message = Message(text: "Hello, Slack!")

        // Act
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(message)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"text\":\"Hello, Slack!\""))
    }

    @Test("Encode message with username and icon")
    func encodeMessageWithUsernameAndIcon() throws {
        // Arrange
        let message = Message(
            text: "Test",
            username: "Test Bot",
            iconEmoji: ":robot_face:"
        )

        // Act
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(message)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"username\":\"Test Bot\""))
        #expect(json.contains("\"icon_emoji\":\":robot_face:\""))
    }

    @Test("Encode message with blocks")
    func encodeMessageWithBlocks() throws {
        // Arrange
        let message = Message(
            text: "Fallback text",
            blocks: [
                HeaderBlock(text: "Header"),
                DividerBlock()
            ]
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"header\""))
        #expect(json.contains("\"type\":\"divider\""))
        #expect(json.contains("\"blocks\""))
    }

    @Test("Encode message with attachments")
    func encodeMessageWithAttachments() throws {
        // Arrange
        let message = Message(
            text: "Test",
            attachments: [
                Attachment(
                    color: "good",
                    title: "Title",
                    text: "Attachment text"
                )
            ]
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"attachments\""))
        #expect(json.contains("\"title\":\"Title\""))
        #expect(json.contains("\"color\":\"good\""))
    }

    @Test("Decode message with blocks")
    func decodeMessageWithBlocks() throws {
        // Arrange
        let jsonString = """
        {
            "text": "Test",
            "blocks": [
                {
                    "type": "section",
                    "text": {
                        "type": "plain_text",
                        "text": "Section text"
                    }
                },
                {
                    "type": "divider"
                }
            ]
        }
        """

        // Act
        let decoder = JSONDecoder()
        let message = try decoder.decode(Message.self, from: jsonString.data(using: .utf8)!)

        // Assert
        #expect(message.text == "Test")
        #expect(message.blocks?.count == 2)
    }

    @Test("Encode message with mrkdwn disabled")
    func encodeMessageWithMrkdwnDisabled() throws {
        // Arrange
        let message = Message(
            text: "Text without *markdown* formatting",
            mrkdwn: false
        )

        // Act
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(message)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"mrkdwn\":false"))
    }

    @Test("Encode message with replyBroadcast")
    func encodeMessageWithReplyBroadcast() throws {
        // Arrange
        let message = Message(
            text: "Broadcast reply",
            threadTimestamp: "1234567890.123456",
            replyBroadcast: true
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"thread_ts\":\"1234567890.123456\""))
        #expect(json.contains("\"reply_broadcast\":true"))
    }

    @Test("Encode Attachment with all fields")
    func encodeAttachmentWithAllFields() throws {
        // Arrange
        let attachment = Attachment(
            fallback: "Fallback text",
            color: "#36a64f",
            pretext: "Pretext",
            authorName: "Author",
            authorLink: "https://example.com",
            authorIcon: "https://example.com/icon.png",
            title: "Title",
            titleLink: "https://example.com/title",
            text: "Attachment text",
            footer: "Footer",
            footerIcon: "https://example.com/footer.png",
            footerTimestamp: 1234567890
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(attachment)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"fallback\":\"Fallback text\""))
        #expect(json.contains("\"color\":\"#36a64f\""))
        #expect(json.contains("\"pretext\":\"Pretext\""))
        #expect(json.contains("\"author_name\":\"Author\""))
        // Note: JSON encoder escapes forward slashes in URLs
        #expect(json.contains("\"author_link\":") && json.contains("example.com"))
        #expect(json.contains("\"author_icon\":") && json.contains("example.com") && json.contains("icon.png"))
        #expect(json.contains("\"title_link\":") && json.contains("example.com") && json.contains("title"))
        #expect(json.contains("\"footer\":\"Footer\""))
        #expect(json.contains("\"footer_icon\":") && json.contains("example.com") && json.contains("footer.png"))
        #expect(json.contains("\"ts\":1234567890"))
    }

    @Test("Encode Attachment with blocks")
    func encodeAttachmentWithBlocks() throws {
        // Arrange
        let attachment = Attachment(
            title: "Attachment with blocks",
            blocks: [
                SectionBlock(text: .plainText("Section in attachment")),
                DividerBlock()
            ]
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(attachment)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"title\":\"Attachment with blocks\""))
        #expect(json.contains("\"blocks\""))
        #expect(json.contains("\"type\":\"section\""))
    }
}
