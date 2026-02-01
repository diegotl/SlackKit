// MARK: - SlackKit

/// SlackKit provides a modern Swift interface for sending messages to Slack via Incoming Webhooks.
///
/// ## Overview
///
/// SlackKit enables Swift applications to send rich, formatted messages to Slack channels
/// using Incoming Webhooks. It supports Slack's Block Kit API for creating interactive,
/// visually appealing messages.
///
/// ## Usage
///
/// ```swift
/// import SlackKit
///
/// // Create a client with your webhook URL
/// let client = SlackWebhookClient(webhookURL: webhookURL)
///
/// // Send a simple text message
/// try await client.send(Message(text: "Hello, Slack!"))
///
/// // Send a message with blocks
/// let message = Message(
///     username: "My Bot",
///     iconEmoji: ":rocket:",
///     blocks: [
///         HeaderBlock(text: "Deployment Complete!"),
///         SectionBlock(text: .markdown("Build <https://ci.example.com|#123> succeeded")),
///         DividerBlock()
///     ]
/// )
/// try await client.send(message)
/// ```
///
/// ## Features
///
/// - **Async/Await**: Modern Swift concurrency support
/// - **Type-Safe**: Full Swift type safety with Codable models
/// - **Block Kit**: Support for all Slack Block Kit elements
/// - **Sendable**: Full Swift 6 concurrency support
/// - **Testable**: Protocol-based networking for easy testing
