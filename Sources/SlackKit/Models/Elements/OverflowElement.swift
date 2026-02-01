import Foundation

// MARK: - OverflowElement

/// An overflow element that displays a menu with multiple options
public struct OverflowElement: BlockElement {
    public let type: String = "overflow"
    public var actionID: String?
    public var options: [Option]

    /// Initializes a new overflow element
    /// - Parameters:
    ///   - actionID: An optional identifier for the action
    ///   - options: The menu options (2-5 options)
    public init(
        actionID: String? = nil,
        options: [Option]
    ) {
        self.actionID = actionID
        self.options = options
    }

    enum CodingKeys: String, CodingKey {
        case type
        case actionID = "action_id"
        case options
    }
}

// MARK: - Option

/// A single option for select menus and overflow menus
public struct Option: Codable, Sendable {
    /// The text to display
    public var text: TextObject

    /// The value to send when the option is selected
    public var value: String

    /// An optional URL to load
    public var url: String?

    /// An optional description
    public var description: TextObject?

    public init(
        text: TextObject,
        value: String,
        url: String? = nil,
        description: TextObject? = nil
    ) {
        self.text = text
        self.value = value
        self.url = url
        self.description = description
    }
}
