import Foundation

// MARK: - OverflowElement Convenience Initializer

extension OverflowElement {
    /// Initializes a new overflow element using a result builder for options
    /// - Parameters:
    ///   - actionID: An optional identifier for the action
    ///   - builder: A result builder closure that provides the options
    public init(
        actionID: String? = nil,
        @OptionsBuilder builder: () -> [Option]
    ) {
        self.actionID = actionID
        self.options = builder()
    }
}
