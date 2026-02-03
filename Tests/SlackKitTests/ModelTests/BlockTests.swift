import Foundation
import Testing
@testable import SlackKit

// MARK: - BlockTests

@Suite("Block Model Tests")
struct BlockTests {

    @Test("Encode SectionBlock")
    func encodeSectionBlock() throws {
        // Arrange
        let block = SectionBlock(
            text: .plainText("Section text"),
            blockID: "section1"
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"section\""))
        #expect(json.contains("\"text\""))
        #expect(json.contains("\"plain_text\""))
        #expect(json.contains("\"Section text\""))
        #expect(json.contains("\"block_id\":\"section1\""))
    }

    @Test("Encode SectionBlock with fields")
    func encodeSectionBlockWithFields() throws {
        // Arrange
        let block = SectionBlock {
            Field.markdown("*Field 1*\nValue 1")
            Field.markdown("*Field 2*\nValue 2")
        }

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"fields\""))
    }

    @Test("Encode DividerBlock")
    func encodeDividerBlock() throws {
        // Arrange
        let block = DividerBlock()

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"divider\""))
    }

    @Test("Encode HeaderBlock")
    func encodeHeaderBlock() throws {
        // Arrange
        let block = HeaderBlock(text: "Header text")

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"header\""))
        #expect(json.contains("\"Header text\""))
    }

    @Test("Encode ImageBlock")
    func encodeImageBlock() throws {
        // Arrange
        let block = ImageBlock(
            imageURL: URL(string: "https://example.com/image.png")!,
            altText: "An image",
            title: .plainText("Image Title")
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"image\""))
        #expect(json.contains("\"image_url\":"))
        #expect(json.contains("\"alt_text\":\"An image\""))
    }

    @Test("Encode ActionsBlock with button")
    func encodeActionsBlockWithButton() throws {
        // Arrange
        let block = Actions {
            ButtonElement(
                text: .plainText("Click me"),
                actionID: "button1",
                value: "button_value"
            )
        }

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"actions\""))
        #expect(json.contains("\"type\":\"button\""))
        #expect(json.contains("\"Click me\""))
    }

    @Test("Encode ContextBlock")
    func encodeContextBlock() throws {
        // Arrange
        let block = Context {
            TextContextElement(text: "Context text")
            ImageContextElement(imageURL: "https://example.com/icon.png", altText: "Icon")
        }

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"context\""))
    }

    @Test("Encode TextObject plain text")
    func encodeTextObjectPlainText() throws {
        // Arrange
        let textObject = TextObject.plainText("Hello", emoji: true)

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(textObject)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"plain_text\""))
        #expect(json.contains("\"text\":\"Hello\""))
        #expect(json.contains("\"emoji\":true"))
    }

    @Test("Encode TextObject markdown")
    func encodeTextObjectMarkdown() throws {
        // Arrange
        let textObject = TextObject.markdown("*Bold* and `code`")

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(textObject)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"mrkdwn\""))
        #expect(json.contains("*Bold* and `code`"))
    }

    @Test("Encode ButtonElement with style")
    func encodeButtonElementWithStyle() throws {
        // Arrange
        let button = ButtonElement(
            text: .plainText("Approve"),
            value: "approve",
            style: .primary
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(button)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"style\":\"primary\""))
    }

    @Test("Encode Option")
    func encodeOption() throws {
        // Arrange
        let option = Option(
            text: .plainText("Option 1"),
            value: "opt1"
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(option)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"text\""))
        #expect(json.contains("\"value\":\"opt1\""))
    }

    @Test("Encode Attachment with fields")
    func encodeAttachmentWithFields() throws {
        // Arrange
        let attachment = Attachment(
            color: "#36a64f",
            title: "Status",
            fields: [
                AttachmentField(title: "Field 1", value: "Value 1", short: true),
                AttachmentField(title: "Field 2", value: "Value 2", short: true)
            ]
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(attachment)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"title\":\"Status\""))
        #expect(json.contains("\"color\":\"#36a64f\""))
        #expect(json.contains("\"fields\""))
    }

    // MARK: - InputBlock Tests

    @Test("Encode InputBlock")
    func encodeInputBlock() throws {
        // Arrange
        let block = InputBlock(
            label: .plainText("Task description"),
            element: PlainTextInputElement(
                placeholder: "Enter task details...",
                multiline: true
            ),
            hint: .plainText("Be specific about the requirements"),
            optional: false,
            blockID: "task_input"
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"input\""))
        #expect(json.contains("\"label\""))
        #expect(json.contains("\"Task description\""))
        #expect(json.contains("\"type\":\"plain_text_input\""))
        #expect(json.contains("\"placeholder\""))
        #expect(json.contains("\"multiline\":true"))
        #expect(json.contains("\"hint\""))
        #expect(json.contains("\"optional\":false"))
        #expect(json.contains("\"block_id\":\"task_input\""))
    }

    @Test("Encode PlainTextInputElement")
    func encodePlainTextInputElement() throws {
        // Arrange
        let element = PlainTextInputElement(
            actionID: "text_input",
            placeholder: "Type something...",
            initialValue: "Initial value",
            multiline: false,
            minLength: 1,
            maxLength: 500
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(element)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"plain_text_input\""))
        #expect(json.contains("\"action_id\":\"text_input\""))
        #expect(json.contains("\"placeholder\""))
        #expect(json.contains("\"initial_value\":\"Initial value\""))
        #expect(json.contains("\"min_length\":1"))
        #expect(json.contains("\"max_length\":500"))
    }

    // MARK: - MultiSelect Tests

    @Test("Encode MultiStaticSelectElement")
    func encodeMultiStaticSelectElement() throws {
        // Arrange
        let element = MultiStaticSelectElement(
            placeholder: .plainText("Select options"),
            maxSelectedItems: 3
        ) {
            Option(text: .plainText("Option 1"), value: "opt1")
            Option(text: .plainText("Option 2"), value: "opt2")
        }

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(element)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"multi_static_select\""))
        #expect(json.contains("\"placeholder\""))
        #expect(json.contains("\"options\""))
        #expect(json.contains("\"max_selected_items\":3"))
    }

    @Test("Encode MultiUsersSelectElement")
    func encodeMultiUsersSelectElement() throws {
        // Arrange
        let element = MultiUsersSelectElement(
            placeholder: .plainText("Select users"),
            initialUsers: ["U123456", "U789012"],
            maxSelectedItems: 5
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(element)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"multi_users_select\""))
        #expect(json.contains("\"initial_users\""))
        #expect(json.contains("\"max_selected_items\":5"))
    }

    @Test("Encode MultiConversationsSelectElement")
    func encodeMultiConversationsSelectElement() throws {
        // Arrange
        let element = MultiConversationsSelectElement(
            placeholder: .plainText("Select conversations"),
            filter: ConversationFilter(
                include: [.public, .private],
                excludeBotUsers: true
            )
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(element)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"multi_conversations_select\""))
        #expect(json.contains("\"filter\""))
        #expect(json.contains("\"include\""))
        #expect(json.contains("\"exclude_bot_users\":true"))
    }

    // MARK: - DatePicker Tests

    @Test("Encode DatePickerElement")
    func encodeDatePickerElement() throws {
        // Arrange
        let element = DatePickerElement(
            actionID: "date_picker_1",
            placeholder: .plainText("Select a date")
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(element)
        let json = String(data: data, encoding: .utf8)!

        // Assert
        #expect(json.contains("\"type\":\"datepicker\""))
        #expect(json.contains("\"action_id\":\"date_picker_1\""))
        #expect(json.contains("\"placeholder\""))
    }
}
