import Foundation

// MARK: - OptionsBuilder

/// A result builder for constructing select menu options
@resultBuilder
public enum OptionsBuilder {
    /// Builds an empty option array
    public static func buildBlock() -> [Option] {
        []
    }

    /// Builds an option array from multiple options
    public static func buildBlock(_ components: [Option]...) -> [Option] {
        components.flatMap { $0 }
    }

    /// Builds an option array from a single option expression
    public static func buildExpression(_ expression: Option) -> [Option] {
        [expression]
    }

    /// Builds an option array from an optional option expression
    public static func buildExpression(_ expression: Option?) -> [Option] {
        expression.map { [$0] } ?? []
    }

    /// Builds an option array from an array of options (pass-through)
    public static func buildExpression(_ expression: [Option]) -> [Option] {
        expression
    }

    /// Builds an option array from an if block
    public static func buildIf(_ content: [Option]?) -> [Option] {
        content ?? []
    }

    /// Builds an option array from an if-else block (first branch)
    public static func buildEither(first component: [Option]) -> [Option] {
        component
    }

    /// Builds an option array from an if-else block (second branch)
    public static func buildEither(second component: [Option]) -> [Option] {
        component
    }

    /// Builds an option array from a for loop
    public static func buildArray(_ components: [[Option]]) -> [Option] {
        components.flatMap { $0 }
    }

    /// Builds the final option array
    public static func buildFinalBlock(_ component: [Option]) -> [Option] {
        component
    }
}

// MARK: - StaticSelectElement Convenience Initializer

extension StaticSelectElement {
    /// Initializes a new static select element using a result builder for options
    /// - Parameters:
    ///   - placeholder: The placeholder text
    ///   - actionID: An optional identifier for the action
    ///   - initialOption: The initially selected option
    ///   - confirm: An optional confirmation dialog
    ///   - builder: A result builder closure that provides the options
    public init(
        placeholder: TextObject,
        actionID: String? = nil,
        initialOption: Option? = nil,
        confirm: ConfirmationDialog? = nil,
        @OptionsBuilder builder: () -> [Option]
    ) {
        self.placeholder = placeholder
        self.actionID = actionID
        self.options = builder()
        self.optionGroups = nil
        self.initialOption = initialOption
        self.confirm = confirm
    }
}

// MARK: - MultiStaticSelectElement Convenience Initializer

extension MultiStaticSelectElement {
    /// Initializes a new multi-select element using a result builder for options
    /// - Parameters:
    ///   - placeholder: The placeholder text
    ///   - actionID: An optional identifier for the action
    ///   - maxSelectedItems: Maximum number of items that can be selected
    ///   - initialOptions: The initially selected options
    ///   - confirm: An optional confirmation dialog
    ///   - builder: A result builder closure that provides the options
    public init(
        placeholder: TextObject,
        actionID: String? = nil,
        maxSelectedItems: Int? = nil,
        initialOptions: [Option]? = nil,
        confirm: ConfirmationDialog? = nil,
        @OptionsBuilder builder: () -> [Option]
    ) {
        self.placeholder = placeholder
        self.actionID = actionID
        self.options = builder()
        self.optionGroups = nil
        self.maxSelectedItems = maxSelectedItems
        self.initialOptions = initialOptions
        self.confirm = confirm
    }
}
