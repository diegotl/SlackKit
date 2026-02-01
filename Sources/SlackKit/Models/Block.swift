import Foundation

// MARK: - Block Protocol

/// A protocol defining a Slack block
public protocol Block: Codable, Sendable {
    /// The type of block
    var type: BlockType { get }

    /// An optional identifier for the block
    var blockID: String? { get set }
}

// MARK: - BlockType

/// The type of a Slack block
public enum BlockType: String, Codable, Sendable {
    case section
    case divider
    case image
    case actions
    case context
    case file
    case header
    case input
    case call
}

// MARK: - BlockElement Protocol

/// A protocol defining a block element (accessory, action, etc.)
public protocol BlockElement: Codable, Sendable {
    /// The type of element
    var type: String { get }
}

// MARK: - ElementType

/// Common element types
public enum ElementType: String, Codable {
    case button
    case overflow
    case datePicker = "datepicker"
    case radioButtons = "radio_buttons"
    case checkboxes
    case plainTextInput = "plain_text_input"
    case staticSelect = "static_select"
    case externalSelect = "external_select"
    case usersSelect = "users_select"
    case conversationsSelect = "conversations_select"
    case channelsSelect = "channels_select"
    case multiStaticSelect = "multi_static_select"
    case multiExternalSelect = "multi_external_select"
    case multiUsersSelect = "multi_users_select"
    case multiConversationsSelect = "multi_conversations_select"
    case multiChannelsSelect = "multi_channels_select"
    case image
}

// MARK: - TextObject

/// A text object for Slack blocks
public enum TextObject: Codable, Sendable {
    /// Plain text
    case plainText(PlainTextField)

    /// Markdown text
    case markdown(MarkdownField)

    /// Creates a plain text object
    public static func plainText(_ text: String, emoji: Bool? = nil) -> TextObject {
        .plainText(PlainTextField(text: text, emoji: emoji))
    }

    /// Creates a markdown text object
    public static func markdown(_ text: String, verbatim: Bool? = nil) -> TextObject {
        .markdown(MarkdownField(text: text, verbatim: verbatim))
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
    }

    private enum ContentType: String, Codable {
        case plainText = "plain_text"
        case markdown = "mrkdwn"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)

        switch type {
        case .plainText:
            self = .plainText(try PlainTextField(from: decoder))
        case .markdown:
            self = .markdown(try MarkdownField(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .plainText(let field):
            try field.encode(to: encoder)
        case .markdown(let field):
            try field.encode(to: encoder)
        }
    }
}

// MARK: - PlainTextField

/// A plain text field
public struct PlainTextField: Codable, Sendable {
    public let type: String = "plain_text"
    public var text: String
    public var emoji: Bool?

    public init(text: String, emoji: Bool? = nil) {
        self.text = text
        self.emoji = emoji
    }

    enum CodingKeys: String, CodingKey {
        case type, text, emoji
    }
}

// MARK: - MarkdownField

/// A markdown text field
public struct MarkdownField: Codable, Sendable {
    public let type: String = "mrkdwn"
    public var text: String
    public var verbatim: Bool?

    public init(text: String, verbatim: Bool? = nil) {
        self.text = text
        self.verbatim = verbatim
    }

    enum CodingKeys: String, CodingKey {
        case type, text, verbatim
    }
}

// MARK: - AnyBlockElement

/// Type erasure wrapper for encoding block elements
public struct AnyBlockElement: Codable, Sendable {
    public let value: any BlockElement

    public init(_ value: any BlockElement) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "button":
            self.value = try ButtonElement(from: decoder)
        case "image":
            self.value = try ImageElement(from: decoder)
        case "overflow":
            self.value = try OverflowElement(from: decoder)
        case "static_select":
            self.value = try StaticSelectElement(from: decoder)
        case "datepicker":
            self.value = try DatePickerElement(from: decoder)
        case "plain_text_input":
            self.value = try PlainTextInputElement(from: decoder)
        case "multi_static_select":
            self.value = try MultiStaticSelectElement(from: decoder)
        case "multi_external_select":
            self.value = try MultiExternalSelectElement(from: decoder)
        case "multi_users_select":
            self.value = try MultiUsersSelectElement(from: decoder)
        case "multi_conversations_select":
            self.value = try MultiConversationsSelectElement(from: decoder)
        case "multi_channels_select":
            self.value = try MultiChannelsSelectElement(from: decoder)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported element type: \(type)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        // BlockElement conforms to Codable, so value is Encodable
        // Cast to Encodable to call encode on the existential type
        try (value as Encodable).encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: - Property Wrapper

/// Property wrapper for handling polymorphic block elements
@propertyWrapper
public struct AnyBlockElementCodable {
    public var wrappedValue: (any BlockElement)?

    public init(wrappedValue: (any BlockElement)? = nil) {
        self.wrappedValue = wrappedValue
    }
}

extension AnyBlockElementCodable: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(AnyBlockElement.self) {
            wrappedValue = value.value
        } else {
            wrappedValue = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let value = wrappedValue {
            var container = encoder.singleValueContainer()
            try container.encode(AnyBlockElement(value))
        }
    }
}

extension AnyBlockElementCodable: Sendable {}

// MARK: - Default BlockID Implementation

extension Block {
    /// Default block ID getter (can be overridden)
    public var blockID: String? {
        get { nil }
        set { }
    }
}
