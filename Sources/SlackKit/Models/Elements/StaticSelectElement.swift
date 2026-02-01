import Foundation

// MARK: - StaticSelectElement

/// A static select menu element that displays a dropdown list of options
public struct StaticSelectElement: BlockElement {
    public let type: String = "static_select"
    public var placeholder: TextObject
    public var actionID: String?
    public var options: [Option]?
    public var optionGroups: [OptionGroup]?
    public var initialOption: Option?
    public var confirm: ConfirmationDialog?

    /// Initializes a new static select element
    /// - Parameters:
    ///   - placeholder: The placeholder text
    ///   - actionID: An optional identifier for the action
    ///   - options: The menu options
    ///   - optionGroups: The menu option groups
    ///   - initialOption: The initially selected option
    ///   - confirm: An optional confirmation dialog
    public init(
        placeholder: TextObject,
        actionID: String? = nil,
        options: [Option]? = nil,
        optionGroups: [OptionGroup]? = nil,
        initialOption: Option? = nil,
        confirm: ConfirmationDialog? = nil
    ) {
        self.placeholder = placeholder
        self.actionID = actionID
        self.options = options
        self.optionGroups = optionGroups
        self.initialOption = initialOption
        self.confirm = confirm
    }

    enum CodingKeys: String, CodingKey {
        case type, placeholder
        case actionID = "action_id"
        case options
        case optionGroups = "option_groups"
        case initialOption = "initial_option"
        case confirm
    }
}

// MARK: - OptionGroup

/// A group of options for select menus
public struct OptionGroup: Codable, Sendable {
    /// A label for the group
    public var label: TextObject

    /// The options in the group
    public var options: [Option]

    public init(label: TextObject, options: [Option]) {
        self.label = label
        self.options = options
    }
}
