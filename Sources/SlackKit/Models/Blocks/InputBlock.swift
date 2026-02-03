import Foundation

// MARK: - InputBlock

/// An input block for collecting user input (only available in modals)
public struct InputBlock: Block {
    public internal(set) var type: BlockType = .input
    public var blockID: String?

    /// A label that appears above the input
    public var label: TextObject

    /// The type of element for this input
    public var element: any BlockElement

    /// A boolean that indicates whether the input value may contain a single value
    /// or multiple values (only applies to multi-select menus)
    public var dispatchAction: Bool?

    /// An optional hint that appears below the input
    public var hint: TextObject?

    /// Whether this input is required or optional
    public var optional: Bool?

    /// Initializes a new input block
    /// - Parameters:
    ///   - label: A label for the input
    ///   - element: The type of element (plain text input, select, etc.)
    ///   - dispatchAction: Whether the input dispatches multiple values
    ///   - hint: An optional hint text
    ///   - optional: Whether the input is optional
    ///   - blockID: An optional identifier for the block
    public init(
        label: TextObject,
        element: any BlockElement,
        dispatchAction: Bool? = nil,
        hint: TextObject? = nil,
        optional: Bool? = nil,
        blockID: String? = nil
    ) {
        self.label = label
        self.element = element
        self.dispatchAction = dispatchAction
        self.hint = hint
        self.optional = optional
        self.blockID = blockID
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case blockID = "block_id"
        case label
        case element
        case dispatchAction = "dispatch_action"
        case hint
        case optional
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BlockType.self, forKey: .type)
        blockID = try container.decodeIfPresent(String.self, forKey: .blockID)
        label = try container.decode(TextObject.self, forKey: .label)
        dispatchAction = try container.decodeIfPresent(Bool.self, forKey: .dispatchAction)
        hint = try container.decodeIfPresent(TextObject.self, forKey: .hint)
        optional = try container.decodeIfPresent(Bool.self, forKey: .optional)

        // Decode element polymorphically
        if let elementContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .element) {
            let elementType = try elementContainer.decode(String.self, forKey: .type)
            let elementDecoder = try container.superDecoder(forKey: .element)

            switch elementType {
            case "plain_text_input":
                element = try PlainTextInputElement(from: elementDecoder)
            case "static_select":
                element = try StaticSelectElement(from: elementDecoder)
            case "datepicker":
                element = try DatePickerElement(from: elementDecoder)
            case "multi_static_select":
                element = try MultiStaticSelectElement(from: elementDecoder)
            case "multi_users_select":
                element = try MultiUsersSelectElement(from: elementDecoder)
            case "multi_conversations_select":
                element = try MultiConversationsSelectElement(from: elementDecoder)
            case "multi_channels_select":
                element = try MultiChannelsSelectElement(from: elementDecoder)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .element,
                    in: container,
                    debugDescription: "Unsupported element type: \(elementType)"
                )
            }
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.element,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "Element not found")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(blockID, forKey: .blockID)
        try container.encode(label, forKey: .label)
        try container.encodeIfPresent(dispatchAction, forKey: .dispatchAction)
        try container.encodeIfPresent(hint, forKey: .hint)
        try container.encodeIfPresent(optional, forKey: .optional)

        // Encode element polymorphically
        try container.encode(element, forKey: .element)
    }
}

// MARK: - PlainTextInputElement

/// A plain text input element
public struct PlainTextInputElement: BlockElement {
    public let type: String = "plain_text_input"
    public var actionID: String?
    public var placeholder: String?
    public var initialValue: String?
    public var multiline: Bool?
    public var minLength: Int?
    public var maxLength: Int?
    public var dispatchActionConfig: DispatchActionConfig?

    /// Initializes a new plain text input element
    /// - Parameters:
    ///   - actionID: An identifier for the action
    ///   - placeholder: Placeholder text
    ///   - initialValue: The initial value
    ///   - multiline: Whether to use multiline input
    ///   - minLength: Minimum length
    ///   - maxLength: Maximum length
    ///   - dispatchActionConfig: Configuration for dispatching actions
    public init(
        actionID: String? = nil,
        placeholder: String? = nil,
        initialValue: String? = nil,
        multiline: Bool? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        dispatchActionConfig: DispatchActionConfig? = nil
    ) {
        self.actionID = actionID
        self.placeholder = placeholder
        self.initialValue = initialValue
        self.multiline = multiline
        self.minLength = minLength
        self.maxLength = maxLength
        self.dispatchActionConfig = dispatchActionConfig
    }

    enum CodingKeys: String, CodingKey {
        case type
        case actionID = "action_id"
        case placeholder
        case initialValue = "initial_value"
        case multiline
        case minLength = "min_length"
        case maxLength = "max_length"
        case dispatchActionConfig = "dispatch_action_config"
    }
}

// MARK: - DispatchActionConfig

/// Configuration for dispatching actions on input
public struct DispatchActionConfig: Codable, Sendable {
    /// An array of trigger IDs from interactive components
    public var triggerActionsOn: [String]?

    /// The type of dispatch action
    public var triggerActionsOnEnabled: Bool?

    public init(
        triggerActionsOn: [String]? = nil,
        triggerActionsOnEnabled: Bool? = nil
    ) {
        self.triggerActionsOn = triggerActionsOn
        self.triggerActionsOnEnabled = triggerActionsOnEnabled
    }

    enum CodingKeys: String, CodingKey {
        case triggerActionsOn = "trigger_actions_on"
        case triggerActionsOnEnabled = "trigger_actions_on_enabled"
    }
}
