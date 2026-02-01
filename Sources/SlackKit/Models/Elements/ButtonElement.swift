import Foundation

// MARK: - ButtonElement

/// A button element that can be clicked to trigger an action
public struct ButtonElement: BlockElement {
    public let type: String = "button"
    public var text: TextObject
    public var actionID: String?
    public var url: String?
    public var value: String?
    public var style: ButtonStyle?
    public var confirm: ConfirmationDialog?

    /// Initializes a new button element
    /// - Parameters:
    ///   - text: The button text
    ///   - actionID: An optional identifier for the action
    ///   - url: An optional URL to open
    ///   - value: An optional value to send with the action
    ///   - style: The button style
    ///   - confirm: An optional confirmation dialog
    public init(
        text: TextObject,
        actionID: String? = nil,
        url: String? = nil,
        value: String? = nil,
        style: ButtonStyle? = nil,
        confirm: ConfirmationDialog? = nil
    ) {
        self.text = text
        self.actionID = actionID
        self.url = url
        self.value = value
        self.style = style
        self.confirm = confirm
    }

    enum CodingKeys: String, CodingKey {
        case type, text
        case actionID = "action_id"
        case url, value, style, confirm
    }
}

// MARK: - ButtonStyle

/// The visual style of a button
public enum ButtonStyle: String, Codable, Sendable {
    /// Default style (usually appears as a gray button)
    case `default`

    /// Primary style (usually appears as a blue or green button)
    case primary

    /// Danger style (usually appears as a red button)
    case danger
}

// MARK: - ConfirmationDialog

/// A confirmation dialog that appears before an action is taken
public struct ConfirmationDialog: Codable, Sendable {
    /// The title of the dialog
    public var title: TextObject

    /// The text of the dialog
    public var text: TextObject

    /// The text for the confirm button
    public var confirm: TextObject

    /// The text for the deny button
    public var deny: TextObject

    /// The style of the confirm button
    public var style: ButtonStyle?

    public init(
        title: TextObject,
        text: TextObject,
        confirm: TextObject,
        deny: TextObject,
        style: ButtonStyle? = nil
    ) {
        self.title = title
        self.text = text
        self.confirm = confirm
        self.deny = deny
        self.style = style
    }
}
