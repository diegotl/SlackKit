import Foundation

// MARK: - MessageBuilder

/// A result builder for constructing Slack messages with blocks
@resultBuilder
public enum MessageBuilder {
    /// Builds an empty block array
    public static func buildBlock() -> [any Block] {
        []
    }

    /// Builds a block array from multiple blocks
    public static func buildBlock(_ components: [any Block]...) -> [any Block] {
        components.flatMap { $0 }
    }

    /// Builds a block array from a single block expression
    public static func buildExpression(_ expression: any Block) -> [any Block] {
        [expression]
    }

    /// Builds a block array from an optional block expression
    public static func buildExpression(_ expression: (any Block)?) -> [any Block] {
        expression.map { [$0] } ?? []
    }

    /// Builds a block array from an array of blocks (pass-through)
    public static func buildExpression(_ expression: [any Block]) -> [any Block] {
        expression
    }

    /// Builds a block array from an if block
    public static func buildIf(_ content: [any Block]?) -> [any Block] {
        content ?? []
    }

    /// Builds a block array from an if-else block (first branch)
    public static func buildEither(first component: [any Block]) -> [any Block] {
        component
    }

    /// Builds a block array from an if-else block (second branch)
    public static func buildEither(second component: [any Block]) -> [any Block] {
        component
    }

    /// Builds a block array from a for loop
    public static func buildArray(_ components: [[any Block]]) -> [any Block] {
        components.flatMap { $0 }
    }

    /// Builds the final block array
    public static func buildFinalBlock(_ component: [any Block]) -> [any Block] {
        component
    }
}

// MARK: - Message Convenience Initializer

extension Message {
    /// Initializes a new message using a result builder with all Message options
    /// - Parameters:
    ///   - text: A plain-text summary of the message
    ///   - blocks: An array of layout blocks (built from result builder)
    ///   - attachments: Legacy attachments
    ///   - username: Override the bot's username
    ///   - iconEmoji: Override the bot's icon with an emoji (e.g., ":rocket:")
    ///   - iconURL: Override the bot's icon with an image URL
    ///   - channel: Send to a specific channel
    ///   - threadTimestamp: Parent message timestamp for threading
    ///   - unfurlLinks: Enable automatic unfurling of links
    ///   - unfurlMedia: Enable automatic unfurling of media
    ///   - replyBroadcast: Reply broadcasts (for threaded messages)
    ///   - mrkdwn: Whether to format message text using mrkdwn formatting
    ///   - content: A result builder closure containing blocks
    /// - Returns: A new message with all specified options
    public init(
        text: String? = nil,
        attachments: [Attachment]? = nil,
        username: String? = nil,
        iconEmoji: String? = nil,
        iconURL: String? = nil,
        channel: String? = nil,
        threadTimestamp: String? = nil,
        unfurlLinks: Bool? = nil,
        unfurlMedia: Bool? = nil,
        replyBroadcast: Bool? = nil,
        mrkdwn: Bool? = nil,
        @MessageBuilder content: () -> [any Block]
    ) {
        let builtBlocks = content()
        self.init(
            text: text,
            blocks: builtBlocks.isEmpty ? nil : builtBlocks,
            attachments: attachments,
            username: username,
            iconEmoji: iconEmoji,
            iconURL: iconURL,
            channel: channel,
            threadTimestamp: threadTimestamp,
            unfurlLinks: unfurlLinks,
            unfurlMedia: unfurlMedia,
            replyBroadcast: replyBroadcast,
            mrkdwn: mrkdwn
        )
    }
}

// MARK: - Block Convenience Functions

/// Helper enum for creating section block fields
public enum Field {
    /// Creates a markdown field
    /// - Parameter string: The markdown string
    /// - Returns: A TextObject with markdown formatting
    public static func markdown(_ string: String) -> TextObject {
        .markdown(string)
    }

    /// Creates a plain text field
    /// - Parameter string: The plain text string
    /// - Returns: A TextObject with plain text formatting
    public static func plainText(_ string: String) -> TextObject {
        .plainText(string)
    }
}

/// Creates a section block with plain text
/// - Parameters:
///   - text: The text string for the section
///   - blockID: An optional identifier for the block
/// - Returns: A section block with the specified text
public func Section(_ text: String, blockID: String? = nil) -> SectionBlock {
    SectionBlock(text: .plainText(text), blockID: blockID)
}

/// Creates a section block with markdown text
/// - Parameters:
///   - markdown: The markdown text string
///   - blockID: An optional identifier for the block
/// - Returns: A section block with markdown text
public func Section(markdown: String, blockID: String? = nil) -> SectionBlock {
    SectionBlock(text: .markdown(markdown), blockID: blockID)
}

/// Creates a section block with fields using a result builder
/// - Parameters:
///   - text: Optional text for the block
///   - accessory: An optional accessory element
///   - blockID: An optional identifier for the block
///   - builder: A result builder closure that provides the fields
/// - Returns: A section block with fields
public func Section(
    text: String? = nil,
    accessory: (any BlockElement)? = nil,
    blockID: String? = nil,
    @FieldsBuilder builder: () -> [TextObject]
) -> SectionBlock {
    SectionBlock(
        text: text.map { .plainText($0) },
        accessory: accessory,
        blockID: blockID,
        builder: builder
    )
}

/// Creates a section block with markdown text and fields using a result builder
/// - Parameters:
///   - markdown: Optional markdown text for the block
///   - accessory: An optional accessory element
///   - blockID: An optional identifier for the block
///   - builder: A result builder closure that provides the fields
/// - Returns: A section block with fields
public func Section(
    markdown: String? = nil,
    accessory: (any BlockElement)? = nil,
    blockID: String? = nil,
    @FieldsBuilder builder: () -> [TextObject]
) -> SectionBlock {
    SectionBlock(
        text: markdown.map { .markdown($0) },
        accessory: accessory,
        blockID: blockID,
        builder: builder
    )
}

/// Creates a divider block
/// - Parameter blockID: An optional identifier for the block
/// - Returns: A divider block
public func Divider(blockID: String? = nil) -> DividerBlock {
    DividerBlock(blockID: blockID)
}

/// Creates a header block with plain text
/// - Parameters:
///   - text: The text string for the header (max 150 characters)
///   - blockID: An optional identifier for the block
/// - Returns: A header block
public func Header(_ text: String, blockID: String? = nil) -> HeaderBlock {
    HeaderBlock(text: .plainText(text), blockID: blockID)
}

/// Creates an image block
/// - Parameters:
///   - url: The URL of the image
///   - altText: Alt text for the image
///   - blockID: An optional identifier for the block
/// - Returns: An image block
public func Image(url: String, altText: String, blockID: String? = nil) -> ImageBlock {
    guard let imageURL = URL(string: url) else {
        fatalError("Invalid URL string: \(url)")
    }
    return ImageBlock(imageURL: imageURL, altText: altText, blockID: blockID)
}

/// Creates a context block with text strings
/// - Parameters:
///   - texts: The text strings to display (converted to TextContextElement)
///   - blockID: An optional identifier for the block
/// - Returns: A context block
public func Context(_ texts: String..., blockID: String? = nil) -> ContextBlock {
    ContextBlock(elements: texts.map { TextContextElement(text: $0) }, blockID: blockID)
}

/// Creates a context block with text elements
/// - Parameters:
///   - elements: The text objects to display (converted to TextContextElement)
///   - blockID: An optional identifier for the block
/// - Returns: A context block
public func Context(elements: [any ContextElement], blockID: String? = nil) -> ContextBlock {
    ContextBlock(elements: elements, blockID: blockID)
}

/// Creates a context block using a result builder
/// - Parameters:
///   - blockID: An optional identifier for the block
///   - builder: A result builder closure that provides the elements
/// - Returns: A context block
public func Context(
    blockID: String? = nil,
    @ContextBuilder builder: () -> [any ContextElement]
) -> ContextBlock {
    ContextBlock(elements: builder(), blockID: blockID)
}

/// Creates an actions block with elements
/// - Parameters:
///   - elements: The interactive elements
///   - blockID: An optional identifier for the block
/// - Returns: An actions block
public func Actions(_ elements: any BlockElement..., blockID: String? = nil) -> ActionsBlock {
    ActionsBlock(elements: elements, blockID: blockID)
}

/// Creates an actions block using a result builder
/// - Parameters:
///   - blockID: An optional identifier for the block
///   - builder: A result builder closure that provides the elements
/// - Returns: An actions block
public func Actions(
    blockID: String? = nil,
    @ActionsBuilder builder: () -> [any BlockElement]
) -> ActionsBlock {
    ActionsBlock(elements: builder(), blockID: blockID)
}

/// Creates an input block
/// - Parameters:
///   - label: The label for the input (as plain text)
///   - element: The input element
///   - blockID: An optional identifier for the block
/// - Returns: An input block
public func Input(label: String, element: any BlockElement, blockID: String? = nil) -> InputBlock {
    InputBlock(label: .plainText(label), element: element, blockID: blockID)
}

/// Creates a call block
/// - Parameters:
///   - callID: The call ID
///   - blockID: An optional identifier for the block
/// - Returns: A call block
public func Call(callID: String, blockID: String? = nil) -> CallBlock {
    CallBlock(callID: callID, blockID: blockID)
}
