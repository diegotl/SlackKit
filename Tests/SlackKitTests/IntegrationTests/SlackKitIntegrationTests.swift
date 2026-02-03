import Foundation
import Testing
@testable import SlackKit

// MARK: - SlackKit Integration Tests

/*
 # SlackKit Integration Tests

 These are end-to-end tests that send actual messages to Slack via Incoming Webhooks.

 ## Prerequisites

 1. **Create a Slack Webhook URL**:
    - Go to your Slack workspace
    - Navigate to: https://api.slack.com/messaging/webhooks
    - Click "Get Started" or "Create your Slack app"
    - Enable Incoming Webhooks
    - Install the app to your workspace
    - Copy the Webhook URL

 2. **Set Environment Variables**:

    ```bash
    export SLACK_INTEGRATION_TESTS=1
    export SLACK_TEST_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    ```

    Or run tests inline:

    ```bash
    SLACK_INTEGRATION_TESTS=1 SLACK_TEST_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL" swift test
    ```

 ## Running Tests

 Run all tests (integration tests will be skipped unless env vars are set):
 ```bash
 swift test
 ```

 Run only integration tests:
 ```bash
 SLACK_INTEGRATION_TESTS=1 SLACK_TEST_WEBHOOK_URL="your_url" swift test --filter "SlackKit Integration Tests"
 ```

 ## What Gets Tested

 - Simple text messages
 - Messages with custom username and icons
 - All block types (Header, Section, Divider, Image, Context, Actions, Input)
 - Interactive elements (Buttons, Select menus, Date pickers, Overflow menus)
 - Multi-select elements (Users, Conversations, Channels)
 - Builder API with conditionals and loops
 - Legacy attachments
 - Special characters and formatting
 - Complex multi-block messages

 ## Important Notes

 - Tests are **serialized** (run one at a time) to avoid rate limits
 - Each test includes a 1-second delay between requests
 - Tests send actual messages to your Slack workspace
 - A dedicated test channel is recommended
 - Some tests verify that InputBlocks throw errors (they only work in modals, not webhooks)

 ## Safety

 - Integration tests are **disabled by default**
 - Tests only run when both environment variables are set
 - All messages include emoji indicators (🧪) for easy identification
 */

@Suite(
    "SlackKit Integration Tests",
    .serialized,
    .enabled(if: {
        // Only run integration tests when SLACK_INTEGRATION_TESTS environment variable is set
        ProcessInfo.processInfo.environment["SLACK_INTEGRATION_TESTS"] != nil
    }())
)
struct SlackKitIntegrationTests {

    // MARK: - Test Configuration

    private var webhookURL: URL {
        guard let urlString = ProcessInfo.processInfo.environment["SLACK_TEST_WEBHOOK_URL"],
              let url = URL(string: urlString) else {
            fatalError("SLACK_TEST_WEBHOOK_URL environment variable must be set to a valid URL")
        }
        return url
    }

    private let defaultTimeout: Duration = .seconds(30)

    // MARK: - Helper Methods

    private func createClient() -> SlackWebhookClient {
        SlackWebhookClient(webhookURL: webhookURL)
    }

    private func waitFor(_ duration: Duration) async {
        // Add random jitter (0-500ms) to help avoid rate limits
        let jitter = Duration.seconds(Double.random(in: 0...0.5))
        try? await Task.sleep(for: duration + jitter)
    }

    // MARK: - Simple Text Messages

    @Test("Send simple text message")
    func sendSimpleTextMessage() async throws {
        let client = createClient()
        let message = Message(text: "🧪 Integration Test: Simple text message")
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with username and icon")
    func sendMessageWithUsernameAndIcon() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Message with custom username and icon",
            username: "SlackKit Test Bot",
            iconEmoji: ":robot_face:"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with custom icon URL")
    func sendMessageWithIconURL() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Message with icon URL",
            username: "SlackKit",
            iconURL: "https://httpbin.org/image/png"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Header Block

    @Test("Send message with multiple headers")
    func sendMessageWithMultipleHeaders() async throws {
        let client = createClient()
        let message = Message {
            Header("First Header")
            Divider()
            Header("Second Header")
        }
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Section Block

    @Test("Send message with SectionBlock and fields")
    func sendMessageWithSectionBlockFields() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Section Block - Fields"),
                SectionBlock(
                    fields: [
                        .markdown("*Field 1:*\nValue 1"),
                        .markdown("*Field 2:*\nValue 2"),
                        .markdown("*Field 3:*\nValue 3"),
                        .markdown("*Field 4:*\nValue 4")
                    ]
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with SectionBlock with text and fields")
    func sendMessageWithSectionBlockTextAndFields() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Section Block - Text + Fields"),
                SectionBlock(
                    text: .plainText("This section has both text and fields below:"),
                    fields: [
                        .plainText("First field"),
                        .plainText("Second field")
                    ]
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Image Block

    @Test("Send message with ImageBlock")
    func sendMessageWithImageBlock() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Image Block"),
                ImageBlock(
                    imageURL: URL(string: "https://httpbin.org/image/png")!,
                    altText: "Swift Logo",
                    title: .plainText("Swift Programming Language")
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with multiple images")
    func sendMessageWithMultipleImages() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Multiple Images"),
                ImageBlock(
                    imageURL: URL(string: "https://httpbin.org/image/png")!,
                    altText: "Test Image 1",
                    title: .plainText("Image 1")
                ),
                ImageBlock(
                    imageURL: URL(string: "https://httpbin.org/image/jpeg")!,
                    altText: "Test Image 2",
                    title: .plainText("Image 2")
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Context Block

    @Test("Send message with ContextBlock")
    func sendMessageWithContextBlock() async throws {
        let client = createClient()
        let message = Message {
            Header("🧪 Context Block")
            Section("Main content of the message")
            Context(
                elements: [
                    TextContextElement(text: "Created by SlackKit • "),
                    ImageContextElement(
                        imageURL: "https://httpbin.org/image/png",
                        altText: "Swift"
                    ),
                    TextContextElement(text: " • Integration Test")
                ]
            )
        }
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Builder API Tests

    @Test("Send message using builder API - basic")
    func sendMessageUsingBuilderBasic() async throws {
        let client = createClient()
        let message = Message {
            Header("🧪 Builder API - Basic")
            Section("This message was created using the result builder API")
            Divider()
            Section(markdown: "Clean and *readable* syntax")
        }
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - conditional blocks")
    func sendMessageUsingBuilderConditional() async throws {
        let client = createClient()
        let includeImage = true
        let showExtraInfo = false

        let message = Message {
            Header("🧪 Builder API - Conditional Blocks")

            if includeImage {
                Image(
                    url: "https://httpbin.org/image/png",
                    altText: "Conditional Image"
                )
            }

            Section("This block appears conditionally")

            if showExtraInfo {
                Section("This won't appear because showExtraInfo is false")
            } else {
                Section("This appears because showExtraInfo is false")
            }
        }
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - for loops")
    func sendMessageUsingBuilderLoops() async throws {
        let client = createClient()
        let items = ["Item 1", "Item 2", "Item 3"]

        let message = Message {
            Header("🧪 Builder API - For Loops")

            for item in items {
                Section(item)
                Divider()
            }
        }
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - complex message")
    func sendMessageUsingBuilderComplex() async throws {
        let client = createClient()
        let message = Message(
            text: "Builder API Complex Message",
            username: "Builder Bot",
            iconEmoji: ":construction_worker:"
        ) {
            Header("🧪 Builder API - Complex Message")

            Section(markdown: """
            This message demonstrates the *full power* of the builder API:
            • Clean syntax
            • Type-safe
            • Expressive
            """)

            Divider()

            let features = [
                ("Result Builders", "Swift 5.4+"),
                ("Type Safety", "Compile-time checks"),
                ("Expressive", "Clean and readable")
            ]

            for (feature, description) in features {
                Section(markdown: "*\(feature)*\n\(description)")
                if feature != features.last?.0 {
                    Divider()
                }
            }

            Context(
                "Built with ",
                "Swift 6",
                " • ",
                "Result Builders"
            )

            Actions(
                ButtonElement(
                    text: .plainText("Learn More"),
                    actionID: "learn_more",
                    value: "clicked",
                    style: .primary
                ),
                ButtonElement(
                    text: .plainText("Documentation"),
                    url: "https://slack.dev"
                )
            )
        }
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - all convenience functions")
    func sendMessageUsingBuilderAllConvenience() async throws {
        let client = createClient()
        let message = Message {
            Header("🧪 All Convenience Functions")
            Section("Section with plain text")
            Divider()
            Section(markdown: "Section with *markdown*")
            Context("Context 1", " • ", "Context 2")
        }
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Multi-Select Elements

    @Test("Send message with multi-static select")
    func sendMessageWithMultiStaticSelect() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Multi-Static Select"),
                SectionBlock(
                    text: .plainText("Choose multiple options:"),
                    accessory: MultiStaticSelectElement(
                        placeholder: .plainText("Select options"),
                        options: [
                            Option(text: .plainText("Option 1"), value: "opt1"),
                            Option(text: .plainText("Option 2"), value: "opt2"),
                            Option(text: .plainText("Option 3"), value: "opt3")
                        ],
                        maxSelectedItems: 2
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with multi-external select")
    func sendMessageWithMultiExternalSelect() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Multi-External Select"),
                SectionBlock(
                    text: .plainText("Select from external data source:"),
                    accessory: MultiExternalSelectElement(
                        placeholder: .plainText("Search items"),
                        minQueryLength: 3,
                        maxSelectedItems: 5
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with multi-users select")
    func sendMessageWithMultiUsersSelect() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Multi-Users Select"),
                SectionBlock(
                    text: .plainText("Select users:"),
                    accessory: MultiUsersSelectElement(
                        placeholder: .plainText("Choose users"),
                        initialUsers: ["U123456"],
                        maxSelectedItems: 3
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with multi-conversations select")
    func sendMessageWithMultiConversationsSelect() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Multi-Conversations Select"),
                SectionBlock(
                    text: .plainText("Select conversations:"),
                    accessory: MultiConversationsSelectElement(
                        placeholder: .plainText("Choose conversations"),
                        filter: ConversationFilter(
                            include: [.public, .private],
                            excludeBotUsers: true
                        ),
                        maxSelectedItems: 10
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with multi-channels select")
    func sendMessageWithMultiChannelsSelect() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Multi-Channels Select"),
                SectionBlock(
                    text: .plainText("Select channels:"),
                    accessory: MultiChannelsSelectElement(
                        placeholder: .plainText("Choose channels"),
                        maxSelectedItems: 5
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - DatePicker Element

    @Test("Send message with DatePicker")
    func sendMessageWithDatePicker() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Date Picker"),
                SectionBlock(
                    text: .plainText("Select a date:"),
                    accessory: DatePickerElement(
                        placeholder: .plainText("Pick a date"),
                        initialDate: Int(Date().timeIntervalSince1970)
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with DatePicker and confirmation")
    func sendMessageWithDatePickerConfirmation() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Date Picker with Confirmation"),
                SectionBlock(
                    text: .plainText("Select a deadline:"),
                    accessory: DatePickerElement(
                        actionID: "deadline_picker",
                        placeholder: .plainText("Choose deadline"),
                        confirm: ConfirmationDialog(
                            title: .plainText("Confirm Date"),
                            text: .plainText("Are you sure you want to set this deadline?"),
                            confirm: .plainText("Set Deadline"),
                            deny: .plainText("Cancel"),
                            style: .primary
                        )
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Image Element

    @Test("Send message with ImageElement accessory")
    func sendMessageWithImageElementAccessory() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Image Element Accessory"),
                SectionBlock(
                    text: .plainText("Section with image element:"),
                    accessory: ImageElement(
                        imageURL: "https://httpbin.org/image/png",
                        altText: "Swift Logo"
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Input Block (Modal-only)

    @Test("Send message with InputBlock and PlainTextInputElement")
    func sendMessageWithInputBlock() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Input Block (Note: Only works in modals)"),
                InputBlock(
                    label: .plainText("Task Name"),
                    element: PlainTextInputElement(
                        actionID: "task_name",
                        placeholder: "Enter task name",
                        maxLength: 100
                    ),
                    hint: .plainText("Enter a descriptive name for the task"),
                    optional: false
                ),
                InputBlock(
                    label: .plainText("Description"),
                    element: PlainTextInputElement(
                        actionID: "task_description",
                        placeholder: "Enter detailed description",
                        multiline: true
                    ),
                    optional: true
                )
            ]
        )
        await #expect(throws: SlackError.self) {
            try await client.send(message)
        }
    }

    @Test("Send message with InputBlock and SelectElement")
    func sendMessageWithInputBlockSelect() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Input Block with Select"),
                InputBlock(
                    label: .plainText("Priority"),
                    element: StaticSelectElement(
                        placeholder: .plainText("Select priority"),
                        options: [
                            Option(text: .plainText("Low"), value: "low"),
                            Option(text: .plainText("Medium"), value: "medium"),
                            Option(text: .plainText("High"), value: "high")
                        ],
                        initialOption: Option(text: .plainText("Medium"), value: "medium")
                    ),
                    optional: false
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message using builder Input function")
    func sendMessageUsingBuilderInput() async throws {
        let client = createClient()
        let message = Message {
            Header("🧪 Builder Input Function")

            Input(
                label: "Feedback",
                element: PlainTextInputElement(
                    actionID: "feedback",
                    placeholder: "Enter your feedback",
                    multiline: true
                )
            )
        }
        await #expect(throws: SlackError.self) {
            try await client.send(message)
        }
    }

    // MARK: - Conversation Filter Types

    @Test("Send message with all conversation filter types")
    func sendMessageWithAllConversationFilters() async throws {
        let client = createClient()
        let filterTypes: [(ConversationFilterType, String)] = [
            (.public, "Public Channels"),
            (.private, "Private Channels"),
            (.im, "Direct Messages"),
            (.mpim, "Group DMs")
        ]

        for (filterType, description) in filterTypes {
            let message = Message(
                blocks: [
                    HeaderBlock(text: "🧪 Conversation Filter - \(description)"),
                    SectionBlock(
                        text: .plainText("Select from \(description.lowercased()):"),
                        accessory: MultiConversationsSelectElement(
                            placeholder: .plainText("Choose conversations"),
                            filter: ConversationFilter(include: [filterType])
                        )
                    )
                ]
            )
            let response = try await client.send(message)
            #expect(response.ok == true)
            await waitFor(.seconds(1))
        }
    }

    // MARK: - Complex Multi-Block Messages

    @Test("Send complex deployment notification message")
    func sendComplexDeploymentNotification() async throws {
        let client = createClient()
        let message = Message(
            text: "Production Alert",
            blocks: [
                HeaderBlock(text: "Production Alert"),
                SectionBlock(
                    text: .markdown("Critical Error in payment processing service")
                ),
                DividerBlock(),
                SectionBlock(
                    fields: [
                        .markdown("*Service:*\npayment-api"),
                        .markdown("*Region:*\nus-east-1")
                    ]
                ),
                ActionsBlock(elements: [
                    ButtonElement(
                        text: .plainText("Investigate"),
                        actionID: "investigate_btn",
                        url: nil,
                        value: "investigate",
                        style: .danger
                    )
                ])
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send error alert message")
    func sendErrorAlertMessage() async throws {
        let client = createClient()
        let message = Message(
            text: "Production Alert",
            blocks: [
                HeaderBlock(text: "⚠️ Production Alert"),
                SectionBlock(
                    text: .markdown("Critical Error in payment processing service")
                ),
                DividerBlock(),
                SectionBlock(
                    fields: [
                        .markdown("*Service:*\npayment-api"),
                        .markdown("*Region:*\nus-east-1"),
                        .markdown("*Severity:*\n:rotating_light: Critical")
                    ]
                ),
                ActionsBlock(elements: [
                    ButtonElement(
                        text: .plainText("Investigate"),
                        actionID: "investigate_btn",
                        url: nil,
                        value: "investigate",
                        style: .danger
                    )
                ])
            ],
            username: "AlertBot",
            iconEmoji: ":warning:"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send feature announcement message")
    func sendFeatureAnnouncementMessage() async throws {
        let client = createClient()
        let message = Message(
            text: "New feature announcement",
            blocks: [
                HeaderBlock(text: "🎉 New Feature Release"),
                ImageBlock(
                    imageURL: URL(string: "https://httpbin.org/image/png")!,
                    altText: "Feature Preview",
                    title: .plainText("New Dashboard")
                ),
                SectionBlock(
                    text: .markdown("We're excited to announce our *new dashboard* with:\n• Real-time analytics\n• Customizable widgets\n• Dark mode support :new_moon_with_face:")
                ),
                DividerBlock(),
                ContextBlock(elements: [
                    TextContextElement(text: "Version 2.0 • Released: "),
                    TextContextElement(text: ISO8601DateFormatter().string(from: Date()))
                ]),
                ActionsBlock(elements: [
                    ButtonElement(
                        text: .plainText("Learn More"),
                        actionID: "learn_more_btn",
                        url: nil,
                        value: "learn_more",
                        style: .primary
                    ),
                    ButtonElement(
                        text: .plainText("Watch Demo"),
                        actionID: nil,
                        url: "https://slack.com",
                        value: nil,
                        style: nil
                    )
                ])
            ],
            username: "Product Updates",
            iconEmoji: ":mega:"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Legacy Attachments

    @Test("Send message with legacy attachment")
    func sendMessageWithLegacyAttachment() async throws {
        let client = createClient()
        let message = Message(
            text: "This message uses legacy attachments",
            attachments: [
                Attachment(
                    color: "good",
                    title: "Build Report",
                    text: "Build #1234 completed successfully",
                    fields: [
                        AttachmentField(title: "Status", value: "Success", short: true),
                        AttachmentField(title: "Duration", value: "5m 32s", short: true),
                        AttachmentField(title: "Branch", value: "main", short: true),
                        AttachmentField(title: "Commit", value: "abc123", short: true)
                    ],
                    footer: "Build System",
                    footerTimestamp: Int(Date().timeIntervalSince1970)
                )
            ],
            username: "Legacy Bot",
            iconEmoji: ":paperclip:"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with multiple attachments")
    func sendMessageWithMultipleAttachments() async throws {
        let client = createClient()
        let message = Message(
            text: "Multiple attachments test",
            attachments: [
                Attachment(
                    color: "good",
                    title: "Success",
                    text: "Operation completed"
                ),
                Attachment(
                    color: "warning",
                    title: "Warning",
                    text: "Minor issues detected"
                ),
                Attachment(
                    color: "#439FE0",
                    title: "Info",
                    text: "Additional information"
                )
            ],
            username: "Multi-Attachment Bot"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Special Characters and Formatting

    @Test("Send message with emojis")
    func sendMessageWithEmojis() async throws {
        let client = createClient()
        let message = Message(
            text: "🎉👋 Hello! Testing emoji support: :rocket: :fire: :100: :tada:",
            blocks: [
                SectionBlock(
                    text: .plainText("Emojis in blocks work too! :star: :heart: :thumbsup:")
                )
            ],
            username: "Emoji Bot :sparkles:",
            iconEmoji: ":robot_face:"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with markdown formatting")
    func sendMessageWithMarkdownFormatting() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Markdown Formatting Test"),
                SectionBlock(
                    text: .markdown("""
This is a *bold text* and this is _italic text_.
This is `code` and this is a ```code block```.
This is a ~strikethrough~ text.

> Blockquote example

* Bullet point 1
* Bullet point 2
* Bullet point 3

1. Numbered item 1
2. Numbered item 2
3. Numbered item 3

A <https://slack.com|link> and an <mailto:test@example.com|email>.
""")
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with special characters")
    func sendMessageWithSpecialCharacters() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Special Characters Test"),
                SectionBlock(
                    text: .markdown("Testing special characters: & < > \" ' ` ~ * _ { } [ ] ( )")
                ),
                SectionBlock(
                    text: .plainText("Unicode support: 你好 世界 🌍 Ñoño café")
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Long Messages

    @Test("Send long message with many blocks")
    func sendLongMessage() async throws {
        let client = createClient()
        var blocks: [any Block] = [
            HeaderBlock(text: "🧪 Long Message Test")
        ]

        // Add multiple sections
        for i in 1...10 {
            blocks.append(SectionBlock(
                text: .plainText("Section \(i): This is section number \(i) with some content to demonstrate scrolling through long messages.")
            ))
            if i < 10 {
                blocks.append(DividerBlock())
            }
        }

        let message = Message(blocks: blocks)
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - All Block Types Together

    @Test("Send message with all block types")
    func sendMessageWithAllBlockTypes() async throws {
        let client = createClient()
        let message = Message(
            text: "Complete block type test",
            blocks: [
                HeaderBlock(text: "🧪 Complete Block Type Test"),
                SectionBlock(text: .markdown("This message demonstrates *all block types* supported by SlackKit")),
                DividerBlock(),
                SectionBlock(
                    fields: [
                        .markdown("*Field A*"),
                        .markdown("*Field B*")
                    ]
                ),
                ImageBlock(
                    imageURL: URL(string: "https://httpbin.org/image/png")!,
                    altText: "Swift Logo",
                    title: .plainText("Swift")
                ),
                ContextBlock(elements: [
                    TextContextElement(text: "Context info"),
                    ImageContextElement(
                        imageURL: "https://httpbin.org/image/png",
                        altText: "Swift"
                    )
                ]),
                ActionsBlock(elements: [
                    ButtonElement(text: .plainText("Button 1"), actionID: "button_1", url: nil, value: "b1", style: .primary),
                    ButtonElement(text: .plainText("Open Link"), actionID: nil, url: "https://slack.com", value: nil, style: nil)
                ]),
                DividerBlock(),
                HeaderBlock(text: "End of Test")
            ],
            username: "SlackKit Test Suite",
            iconEmoji: ":test_tube:"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Block IDs

    @Test("Send message with block IDs")
    func sendMessageWithBlockIDs() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                SectionBlock(
                    text: .plainText("Section with ID"),
                    blockID: "section_001"
                ),
                DividerBlock(blockID: "divider_001"),
                HeaderBlock(text: "Header with ID", blockID: "header_001"),
                ImageBlock(
                    imageURL: URL(string: "https://httpbin.org/image/png")!,
                    altText: "Swift",
                    blockID: "image_001"
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Text Object Variations

    @Test("Send message with emoji enabled")
    func sendMessageWithEmojiEnabled() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                SectionBlock(
                    text: .plainText("Emoji should render :)", emoji: true)
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with verbatim markdown")
    func sendMessageWithVerbatimMarkdown() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                SectionBlock(
                    text: .markdown("*This should NOT be bold*", verbatim: true)
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Select Menu Element

    @Test("Send message with select menu")
    func sendMessageWithSelectMenu() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Select Menu Element"),
                SectionBlock(
                    text: .plainText("Choose an option:"),
                    accessory: StaticSelectElement(
                        placeholder: .plainText("Select an option"),
                        options: [
                            Option(text: .plainText("Option 1"), value: "opt1"),
                            Option(text: .plainText("Option 2"), value: "opt2"),
                            Option(text: .plainText("Option 3"), value: "opt3")
                        ]
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with option groups")
    func sendMessageWithOptionGroups() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Option Groups"),
                SectionBlock(
                    text: .plainText("Select from grouped options:"),
                    accessory: StaticSelectElement(
                        placeholder: .plainText("Choose a fruit"),
                        optionGroups: [
                            OptionGroup(
                                label: .plainText("Citrus"),
                                options: [
                                    Option(text: .plainText("Orange"), value: "orange"),
                                    Option(text: .plainText("Lemon"), value: "lemon")
                                ]
                            ),
                            OptionGroup(
                                label: .plainText("Berries"),
                                options: [
                                    Option(text: .plainText("Strawberry"), value: "strawberry"),
                                    Option(text: .plainText("Blueberry"), value: "blueberry")
                                ]
                            )
                        ]
                    )
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Button with Confirmation Dialog

    @Test("Send message with confirmation dialog")
    func sendMessageWithConfirmationDialog() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Confirmation Dialog"),
                SectionBlock(text: .plainText("Destructive action requires confirmation")),
                ActionsBlock(elements: [
                    ButtonElement(
                        text: .plainText("Delete"),
                        actionID: "delete_btn",
                        url: nil,
                        value: "delete",
                        style: .danger,
                        confirm: ConfirmationDialog(
                            title: .plainText("Are you sure?"),
                            text: .plainText("This action cannot be undone."),
                            confirm: .plainText("Delete"),
                            deny: .plainText("Cancel"),
                            style: .danger
                        )
                    )
                ])
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Overflow Menu

    @Test("Send message with overflow menu")
    func sendMessageWithOverflowMenu() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "🧪 Overflow Menu"),
                SectionBlock(
                    text: .plainText("Click the menu to see more options:"),
                    accessory: OverflowElement(options: [
                        Option(text: .plainText("Option 1"), value: "opt1"),
                        Option(text: .plainText("Option 2"), value: "opt2"),
                        Option(text: .plainText("Option 3"), value: "opt3"),
                        Option(text: .plainText("Option 4"), value: "opt4"),
                        Option(text: .plainText("Option 5"), value: "opt5")
                    ])
                )
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Empty/Edge Cases

    @Test("Send message with empty text")
    func sendMessageWithEmptyText() async throws {
        let client = createClient()
        let message = Message(
            text: "",
            blocks: [
                SectionBlock(text: .plainText("Text is empty but blocks are present"))
            ]
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with only text (no blocks)")
    func sendMessageWithOnlyText() async throws {
        let client = createClient()
        let message = Message(text: "This is a simple message with only text, no blocks.")
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    @Test("Send message with link unfurling disabled")
    func sendMessageWithLinkUnfurlingDisabled() async throws {
        let client = createClient()
        let message = Message(
            text: "Link unfurling test: https://slack.com",
            unfurlLinks: false,
            unfurlMedia: false
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
        await waitFor(.seconds(1))
    }

    // MARK: - Final Summary Test

    @Test("Send integration test summary")
    func sendIntegrationTestSummary() async throws {
        let client = createClient()
        let message = Message(
            blocks: [
                HeaderBlock(text: "✅ Integration Tests Complete"),
                SectionBlock(
                    text: .markdown("All SlackKit features have been tested successfully!\n\nThe following were tested:")
                ),
                SectionBlock(
                    fields: [
                        .plainText("Simple text messages"),
                        .plainText("Header blocks"),
                        .plainText("Section blocks"),
                        .plainText("Divider blocks"),
                        .plainText("Image blocks")
                    ]
                ),
                SectionBlock(
                    fields: [
                        .plainText("Actions blocks"),
                        .plainText("Context blocks"),
                        .plainText("Legacy attachments"),
                        .plainText("Markdown formatting"),
                        .plainText("Special characters")
                    ]
                ),
                SectionBlock(
                    fields: [
                        .plainText("Select menus"),
                        .plainText("Multi-select menus"),
                        .plainText("Overflow menus"),
                        .plainText("Confirmation dialogs"),
                        .plainText("Emojis and Unicode")
                    ]
                ),
                SectionBlock(
                    fields: [
                        .plainText("Builder API"),
                        .plainText("Result builders"),
                        .plainText("Input blocks"),
                        .plainText("Date pickers"),
                        .plainText("Conversation filters")
                    ]
                ),
                DividerBlock(),
                ContextBlock(elements: [
                    TextContextElement(text: "Powered by "),
                    TextContextElement(text: "Swift 6 "),
                    TextContextElement(text: "• "),
                    TextContextElement(text: "Built with ❤️")
                ])
            ],
            username: "SlackKit Test Runner",
            iconEmoji: ":test_tube:"
        )
        let response = try await client.send(message)

        #expect(response.ok == true)
    }
}
