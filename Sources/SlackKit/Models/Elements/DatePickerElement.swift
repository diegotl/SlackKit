import Foundation

// MARK: - DatePickerElement

/// A date picker element for selecting dates
public struct DatePickerElement: BlockElement {
    public let type: String = "datepicker"
    public var actionID: String?
    public var placeholder: TextObject
    public var initialDate: String?
    public var confirm: ConfirmationDialog?

    /// Initializes a new date picker element
    /// - Parameters:
    ///   - actionID: An identifier for the action
    ///   - placeholder: The placeholder text
    ///   - initialDate: The initial date in YYYY-MM-DD format
    ///   - confirm: An optional confirmation dialog
    public init(
        actionID: String? = nil,
        placeholder: TextObject,
        initialDate: String? = nil,
        confirm: ConfirmationDialog? = nil
    ) {
        self.actionID = actionID
        self.placeholder = placeholder
        self.initialDate = initialDate
        self.confirm = confirm
    }

    /// Creates a date string in YYYY-MM-DD format from a Date
    /// - Parameter date: The date to format
    /// - Returns: A string in YYYY-MM-DD format
    public static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case actionID = "action_id"
        case placeholder
        case initialDate = "initial_date"
        case confirm
    }
}
