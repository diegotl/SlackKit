import Foundation

// MARK: - MultiSelectElement Protocol

/// Protocol for multi-select menu elements
public protocol MultiSelectElement: BlockElement {
    /// A placeholder text object
    var placeholder: TextObject { get }
    /// An identifier for the action
    var actionID: String? { get }
    /// An optional confirmation dialog
    var confirm: ConfirmationDialog? { get }
    /// The maximum number of items that can be selected
    var maxSelectedItems: Int? { get }
}

// MARK: - MultiStaticSelectElement

/// A multi-select menu with static options
public struct MultiStaticSelectElement: MultiSelectElement {
    public let type: String = "multi_static_select"
    public var placeholder: TextObject
    public var actionID: String?
    public var options: [Option]?
    public var optionGroups: [OptionGroup]?
    public var initialOptions: [Option]?
    public var confirm: ConfirmationDialog?
    public var maxSelectedItems: Int?

    public init(
        placeholder: TextObject,
        actionID: String? = nil,
        options: [Option]? = nil,
        optionGroups: [OptionGroup]? = nil,
        initialOptions: [Option]? = nil,
        confirm: ConfirmationDialog? = nil,
        maxSelectedItems: Int? = nil
    ) {
        self.placeholder = placeholder
        self.actionID = actionID
        self.options = options
        self.optionGroups = optionGroups
        self.initialOptions = initialOptions
        self.confirm = confirm
        self.maxSelectedItems = maxSelectedItems
    }

    enum CodingKeys: String, CodingKey {
        case type, placeholder
        case actionID = "action_id"
        case options
        case optionGroups = "option_groups"
        case initialOptions = "initial_options"
        case confirm
        case maxSelectedItems = "max_selected_items"
    }
}

// MARK: - MultiExternalSelectElement

/// A multi-select menu with options loaded from an external source
public struct MultiExternalSelectElement: MultiSelectElement {
    public let type: String = "multi_external_select"
    public var placeholder: TextObject
    public var actionID: String?
    public var minQueryLength: Int?
    public var confirm: ConfirmationDialog?
    public var maxSelectedItems: Int?

    public init(
        placeholder: TextObject,
        actionID: String? = nil,
        minQueryLength: Int? = nil,
        confirm: ConfirmationDialog? = nil,
        maxSelectedItems: Int? = nil
    ) {
        self.placeholder = placeholder
        self.actionID = actionID
        self.minQueryLength = minQueryLength
        self.confirm = confirm
        self.maxSelectedItems = maxSelectedItems
    }

    enum CodingKeys: String, CodingKey {
        case type, placeholder
        case actionID = "action_id"
        case minQueryLength = "min_query_length"
        case confirm
        case maxSelectedItems = "max_selected_items"
    }
}

// MARK: - MultiUsersSelectElement

/// A multi-select menu for selecting users
public struct MultiUsersSelectElement: MultiSelectElement {
    public let type: String = "multi_users_select"
    public var placeholder: TextObject
    public var actionID: String?
    public var initialUsers: [String]?
    public var confirm: ConfirmationDialog?
    public var maxSelectedItems: Int?

    public init(
        placeholder: TextObject,
        actionID: String? = nil,
        initialUsers: [String]? = nil,
        confirm: ConfirmationDialog? = nil,
        maxSelectedItems: Int? = nil
    ) {
        self.placeholder = placeholder
        self.actionID = actionID
        self.initialUsers = initialUsers
        self.confirm = confirm
        self.maxSelectedItems = maxSelectedItems
    }

    enum CodingKeys: String, CodingKey {
        case type, placeholder
        case actionID = "action_id"
        case initialUsers = "initial_users"
        case confirm
        case maxSelectedItems = "max_selected_items"
    }
}

// MARK: - MultiConversationsSelectElement

/// A multi-select menu for selecting conversations
public struct MultiConversationsSelectElement: MultiSelectElement {
    public let type: String = "multi_conversations_select"
    public var placeholder: TextObject
    public var actionID: String?
    public var initialConversations: [String]?
    public var defaultToCurrentConversation: Bool?
    public var filter: ConversationFilter?
    public var confirm: ConfirmationDialog?
    public var maxSelectedItems: Int?

    public init(
        placeholder: TextObject,
        actionID: String? = nil,
        initialConversations: [String]? = nil,
        defaultToCurrentConversation: Bool? = nil,
        filter: ConversationFilter? = nil,
        confirm: ConfirmationDialog? = nil,
        maxSelectedItems: Int? = nil
    ) {
        self.placeholder = placeholder
        self.actionID = actionID
        self.initialConversations = initialConversations
        self.defaultToCurrentConversation = defaultToCurrentConversation
        self.filter = filter
        self.confirm = confirm
        self.maxSelectedItems = maxSelectedItems
    }

    enum CodingKeys: String, CodingKey {
        case type, placeholder
        case actionID = "action_id"
        case initialConversations = "initial_conversations"
        case defaultToCurrentConversation = "default_to_current_conversation"
        case filter
        case confirm
        case maxSelectedItems = "max_selected_items"
    }
}

// MARK: - MultiChannelsSelectElement

/// A multi-select menu for selecting channels
public struct MultiChannelsSelectElement: MultiSelectElement {
    public let type: String = "multi_channels_select"
    public var placeholder: TextObject
    public var actionID: String?
    public var initialChannels: [String]?
    public var defaultToCurrentConversation: Bool?
    public var confirm: ConfirmationDialog?
    public var maxSelectedItems: Int?

    public init(
        placeholder: TextObject,
        actionID: String? = nil,
        initialChannels: [String]? = nil,
        defaultToCurrentConversation: Bool? = nil,
        confirm: ConfirmationDialog? = nil,
        maxSelectedItems: Int? = nil
    ) {
        self.placeholder = placeholder
        self.actionID = actionID
        self.initialChannels = initialChannels
        self.defaultToCurrentConversation = defaultToCurrentConversation
        self.confirm = confirm
        self.maxSelectedItems = maxSelectedItems
    }

    enum CodingKeys: String, CodingKey {
        case type, placeholder
        case actionID = "action_id"
        case initialChannels = "initial_channels"
        case defaultToCurrentConversation = "default_to_current_conversation"
        case confirm
        case maxSelectedItems = "max_selected_items"
    }
}

// MARK: - ConversationFilter

/// Filter for conversation select menus
public struct ConversationFilter: Codable, Sendable {
    /// Which conversations to include
    public var include: [ConversationFilterType]?
    /// Whether to exclude external shared channels from public channels
    public var excludeBotUsers: Bool?

    public init(
        include: [ConversationFilterType]? = nil,
        excludeBotUsers: Bool? = nil
    ) {
        self.include = include
        self.excludeBotUsers = excludeBotUsers
    }

    enum CodingKeys: String, CodingKey {
        case include
        case excludeBotUsers = "exclude_bot_users"
    }
}

// MARK: - ConversationFilterType

/// Types of conversations to include in filter
public enum ConversationFilterType: String, Codable, Sendable {
    case `public`
    case `private`
    case im
    case mpim
}

