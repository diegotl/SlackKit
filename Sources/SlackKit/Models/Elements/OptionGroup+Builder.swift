import Foundation

// MARK: - OptionGroup Convenience Initializer

extension OptionGroup {
    /// Initializes a new option group using a result builder for options
    /// - Parameters:
    ///   - label: A label for the group
    ///   - builder: A result builder closure that provides the options
    public init(
        label: TextObject,
        @OptionsBuilder builder: () -> [Option]
    ) {
        self.label = label
        self.options = builder()
    }
}
