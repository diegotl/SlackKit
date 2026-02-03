import Foundation

// MARK: - FieldsBuilder

/// A result builder for constructing SectionBlock fields
@resultBuilder
public enum FieldsBuilder {
    /// Builds an empty field array
    public static func buildBlock() -> [TextObject] {
        []
    }

    /// Builds a field array from multiple fields
    public static func buildBlock(_ components: [TextObject]...) -> [TextObject] {
        components.flatMap { $0 }
    }

    /// Builds a field array from a single field expression
    public static func buildExpression(_ expression: TextObject) -> [TextObject] {
        [expression]
    }

    /// Builds a field array from an optional field expression
    public static func buildExpression(_ expression: TextObject?) -> [TextObject] {
        expression.map { [$0] } ?? []
    }

    /// Builds a field array from an array of fields (pass-through)
    public static func buildExpression(_ expression: [TextObject]) -> [TextObject] {
        expression
    }

    /// Builds a field array from an if block
    public static func buildIf(_ content: [TextObject]?) -> [TextObject] {
        content ?? []
    }

    /// Builds a field array from an if-else block (first branch)
    public static func buildEither(first component: [TextObject]) -> [TextObject] {
        component
    }

    /// Builds a field array from an if-else block (second branch)
    public static func buildEither(second component: [TextObject]) -> [TextObject] {
        component
    }

    /// Builds a field array from a for loop
    public static func buildArray(_ components: [[TextObject]]) -> [TextObject] {
        components.flatMap { $0 }
    }

    /// Builds the final field array
    public static func buildFinalBlock(_ component: [TextObject]) -> [TextObject] {
        component
    }
}

// MARK: - SectionBlock Convenience Initializer

extension SectionBlock {
    /// Initializes a new section block with fields using a result builder
    /// - Parameters:
    ///   - text: Optional text for the block
    ///   - accessory: An optional accessory element
    ///   - blockID: An optional identifier for the block
    ///   - builder: A result builder closure that provides the fields
    public init(
        text: TextObject? = nil,
        accessory: (any BlockElement)? = nil,
        blockID: String? = nil,
        @FieldsBuilder builder: () -> [TextObject]
    ) {
        self.text = text
        self.fields = builder()
        self.accessory = accessory
        self.blockID = blockID
    }
}
