import Foundation

// MARK: - Message

/// A Slack webhook message
public struct Message: Sendable {
    /// A plain-text summary of the message (required when using blocks)
    public var text: String?

    /// An array of layout blocks
    public var blocks: [any Block]?

    /// Legacy attachments (for compatibility)
    public var attachments: [Attachment]?

    /// Overrides the bot's username
    public var username: String?

    /// Overrides the bot's icon with an emoji
    public var iconEmoji: String?

    /// Overrides the bot's icon with an image URL
    public var iconURL: String?

    /// Send messages to a specific channel instead of the webhook default
    public var channel: String?

    /// Parent message timestamp for threaded messages
    public var threadTimestamp: String?

    /// Enable automatic unfurling of links
    public var unfurlLinks: Bool?

    /// Enable automatic unfurling of media
    public var unfurlMedia: Bool?

    /// Reply broadcasts (for threaded messages in channels)
    public var replyBroadcast: Bool?

    /// Whether to format message text using mrkdwn formatting
    public var mrkdwn: Bool?

    /// Initializes a new message
    /// - Parameters:
    ///   - text: A plain-text summary of the message
    ///   - blocks: An array of layout blocks
    ///   - attachments: Legacy attachments
    ///   - username: Override the bot's username
    ///   - iconEmoji: Override the bot's icon with an emoji (e.g., ":rocket:")
    ///   - iconURL: Override the bot's icon with an image URL
    ///   - channel: Send to a specific channel
    ///   - threadTimestamp: Parent message timestamp for threading
    ///   - unfurlLinks: Enable automatic unfurling of links
    ///   - unfurlMedia: Enable automatic unfurling of media
    ///   - replyBroadcast: Reply broadcasts (for threaded messages)
    public init(
        text: String? = nil,
        blocks: [any Block]? = nil,
        attachments: [Attachment]? = nil,
        username: String? = nil,
        iconEmoji: String? = nil,
        iconURL: String? = nil,
        channel: String? = nil,
        threadTimestamp: String? = nil,
        unfurlLinks: Bool? = nil,
        unfurlMedia: Bool? = nil,
        replyBroadcast: Bool? = nil,
        mrkdwn: Bool? = nil
    ) {
        self.text = text
        self.blocks = blocks
        self.attachments = attachments
        self.username = username
        self.iconEmoji = iconEmoji
        self.iconURL = iconURL
        self.channel = channel
        self.threadTimestamp = threadTimestamp
        self.unfurlLinks = unfurlLinks
        self.unfurlMedia = unfurlMedia
        self.replyBroadcast = replyBroadcast
        self.mrkdwn = mrkdwn
    }
}

// MARK: - Codable

extension Message: Codable {
    enum CodingKeys: String, CodingKey {
        case text
        case blocks
        case attachments
        case username
        case iconEmoji = "icon_emoji"
        case iconURL = "icon_url"
        case channel
        case threadTimestamp = "thread_ts"
        case unfurlLinks = "unfurl_links"
        case unfurlMedia = "unfurl_media"
        case replyBroadcast = "reply_broadcast"
        case mrkdwn
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        iconEmoji = try container.decodeIfPresent(String.self, forKey: .iconEmoji)
        iconURL = try container.decodeIfPresent(String.self, forKey: .iconURL)
        channel = try container.decodeIfPresent(String.self, forKey: .channel)
        threadTimestamp = try container.decodeIfPresent(String.self, forKey: .threadTimestamp)
        unfurlLinks = try container.decodeIfPresent(Bool.self, forKey: .unfurlLinks)
        unfurlMedia = try container.decodeIfPresent(Bool.self, forKey: .unfurlMedia)
        replyBroadcast = try container.decodeIfPresent(Bool.self, forKey: .replyBroadcast)
        mrkdwn = try container.decodeIfPresent(Bool.self, forKey: .mrkdwn)

        // Decode blocks polymorphically
        if var blocksContainer = try? container.nestedUnkeyedContainer(forKey: .blocks) {
            var decodedBlocks: [any Block] = []
            while !blocksContainer.isAtEnd {
                if let block = try? blocksContainer.decode(SectionBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(DividerBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(HeaderBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(ImageBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(ActionsBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(ContextBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(InputBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(CallBlock.self) {
                    decodedBlocks.append(block)
                } else {
                    // Skip unknown block types
                    _ = try? blocksContainer.decode(BlockWrapper.self)
                }
            }
            blocks = decodedBlocks.isEmpty ? nil : decodedBlocks
        } else {
            blocks = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(attachments, forKey: .attachments)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(iconEmoji, forKey: .iconEmoji)
        try container.encodeIfPresent(iconURL, forKey: .iconURL)
        try container.encodeIfPresent(channel, forKey: .channel)
        try container.encodeIfPresent(threadTimestamp, forKey: .threadTimestamp)
        try container.encodeIfPresent(unfurlLinks, forKey: .unfurlLinks)
        try container.encodeIfPresent(unfurlMedia, forKey: .unfurlMedia)
        try container.encodeIfPresent(replyBroadcast, forKey: .replyBroadcast)
        try container.encodeIfPresent(mrkdwn, forKey: .mrkdwn)

        // Encode blocks polymorphically
        if let blocks = blocks {
            var blocksContainer = container.nestedUnkeyedContainer(forKey: .blocks)
            for block in blocks {
                try blocksContainer.encode(AnyBlock(block))
            }
        }
    }
}

// MARK: - BlockWrapper

/// Helper type for decoding unknown block types
private struct BlockWrapper: Codable {
    let type: String
}

// MARK: - AnyBlock

/// Type erasure wrapper for encoding blocks
private struct AnyBlock: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ block: any Block) {
        _encode = block.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - Attachment

/// A legacy Slack attachment
public struct Attachment: Codable, Sendable {
    /// A plain-text summary of the attachment
    public var fallback: String?

    /// The attachment color
    public var color: String?

    /// Text that appears above the attachment
    public var pretext: String?

    /// The author name
    public var authorName: String?

    /// The author link
    public var authorLink: String?

    /// The author icon URL
    public var authorIcon: String?

    /// The attachment title
    public var title: String?

    /// The title link
    public var titleLink: String?

    /// The attachment text
    public var text: String?

    /// The attachment fields
    public var fields: [AttachmentField]?

    /// The attachment image URL
    public var imageURL: String?

    /// The attachment thumb URL
    public var thumbURL: String?

    /// The attachment footer
    public var footer: String?

    /// The footer icon URL
    public var footerIcon: String?

    /// Timestamp for the footer
    public var footerTimestamp: Int?

    /// Blocks within the attachment
    public var blocks: [any Block]?

    public init(
        fallback: String? = nil,
        color: String? = nil,
        pretext: String? = nil,
        authorName: String? = nil,
        authorLink: String? = nil,
        authorIcon: String? = nil,
        title: String? = nil,
        titleLink: String? = nil,
        text: String? = nil,
        fields: [AttachmentField]? = nil,
        imageURL: String? = nil,
        thumbURL: String? = nil,
        footer: String? = nil,
        footerIcon: String? = nil,
        footerTimestamp: Int? = nil,
        blocks: [any Block]? = nil
    ) {
        self.fallback = fallback
        self.color = color
        self.pretext = pretext
        self.authorName = authorName
        self.authorLink = authorLink
        self.authorIcon = authorIcon
        self.title = title
        self.titleLink = titleLink
        self.text = text
        self.fields = fields
        self.imageURL = imageURL
        self.thumbURL = thumbURL
        self.footer = footer
        self.footerIcon = footerIcon
        self.footerTimestamp = footerTimestamp
        self.blocks = blocks
    }

    enum CodingKeys: String, CodingKey {
        case fallback
        case color
        case pretext
        case authorName = "author_name"
        case authorLink = "author_link"
        case authorIcon = "author_icon"
        case title
        case titleLink = "title_link"
        case text
        case fields
        case imageURL = "image_url"
        case thumbURL = "thumb_url"
        case footer
        case footerIcon = "footer_icon"
        case footerTimestamp = "ts"
        case blocks
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fallback = try container.decodeIfPresent(String.self, forKey: .fallback)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        pretext = try container.decodeIfPresent(String.self, forKey: .pretext)
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        authorLink = try container.decodeIfPresent(String.self, forKey: .authorLink)
        authorIcon = try container.decodeIfPresent(String.self, forKey: .authorIcon)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        titleLink = try container.decodeIfPresent(String.self, forKey: .titleLink)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        fields = try container.decodeIfPresent([AttachmentField].self, forKey: .fields)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        thumbURL = try container.decodeIfPresent(String.self, forKey: .thumbURL)
        footer = try container.decodeIfPresent(String.self, forKey: .footer)
        footerIcon = try container.decodeIfPresent(String.self, forKey: .footerIcon)
        footerTimestamp = try container.decodeIfPresent(Int.self, forKey: .footerTimestamp)

        // Decode blocks polymorphically
        if var blocksContainer = try? container.nestedUnkeyedContainer(forKey: .blocks) {
            var decodedBlocks: [any Block] = []
            while !blocksContainer.isAtEnd {
                if let block = try? blocksContainer.decode(SectionBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(DividerBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(HeaderBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(ImageBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(ActionsBlock.self) {
                    decodedBlocks.append(block)
                } else if let block = try? blocksContainer.decode(ContextBlock.self) {
                    decodedBlocks.append(block)
                } else {
                    _ = try? blocksContainer.decode(BlockWrapper.self)
                }
            }
            blocks = decodedBlocks.isEmpty ? nil : decodedBlocks
        } else {
            blocks = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fallback, forKey: .fallback)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(pretext, forKey: .pretext)
        try container.encodeIfPresent(authorName, forKey: .authorName)
        try container.encodeIfPresent(authorLink, forKey: .authorLink)
        try container.encodeIfPresent(authorIcon, forKey: .authorIcon)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(titleLink, forKey: .titleLink)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(fields, forKey: .fields)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(thumbURL, forKey: .thumbURL)
        try container.encodeIfPresent(footer, forKey: .footer)
        try container.encodeIfPresent(footerIcon, forKey: .footerIcon)
        try container.encodeIfPresent(footerTimestamp, forKey: .footerTimestamp)

        // Encode blocks polymorphically
        if let blocks = blocks {
            var blocksContainer = container.nestedUnkeyedContainer(forKey: .blocks)
            for block in blocks {
                try blocksContainer.encode(AnyBlock(block))
            }
        }
    }
}

// MARK: - AttachmentField

/// An attachment field
public struct AttachmentField: Codable, Sendable {
    /// The field title
    public var title: String

    /// The field value
    public var value: String

    /// Whether the value is short
    public var short: Bool?

    public init(title: String, value: String, short: Bool? = nil) {
        self.title = title
        self.value = value
        self.short = short
    }
}
