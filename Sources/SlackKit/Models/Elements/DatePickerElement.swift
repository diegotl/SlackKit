import Foundation

// MARK: - DatePickerElement

/// A date picker element for selecting dates
public struct DatePickerElement: BlockElement {
    public let type: String = "datepicker"
    public var actionID: String?
    public var placeholder: TextObject
    public var initialDate: Int?
    public var confirm: ConfirmationDialog?

    /// Initializes a new date picker element
    /// - Parameters:
    ///   - actionID: An identifier for the action
    ///   - placeholder: The placeholder text
    ///   - initialDate: The initial date as a Unix timestamp
    ///   - confirm: An optional confirmation dialog
    public init(
        actionID: String? = nil,
        placeholder: TextObject,
        initialDate: Int? = nil,
        confirm: ConfirmationDialog? = nil
    ) {
        self.actionID = actionID
        self.placeholder = placeholder
        self.initialDate = initialDate
        self.confirm = confirm
    }

    enum CodingKeys: String, CodingKey {
        case type
        case actionID = "action_id"
        case placeholder
        case initialDate = "initial_date"
        case confirm
    }
}
