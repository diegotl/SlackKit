import Foundation

// MARK: - ContextBuilder

/// A result builder for constructing ContextBlock elements
@resultBuilder
public enum ContextBuilder {
    /// Builds an empty element array
    public static func buildBlock() -> [any ContextElement] {
        []
    }

    /// Builds an element array from multiple elements
    public static func buildBlock(_ components: [any ContextElement]...) -> [any ContextElement] {
        components.flatMap { $0 }
    }

    /// Builds an element array from a single element expression
    public static func buildExpression(_ expression: any ContextElement) -> [any ContextElement] {
        [expression]
    }

    /// Builds an element array from an optional element expression
    public static func buildExpression(_ expression: (any ContextElement)?) -> [any ContextElement] {
        expression.map { [$0] } ?? []
    }

    /// Builds an element array from an array of elements (pass-through)
    public static func buildExpression(_ expression: [any ContextElement]) -> [any ContextElement] {
        expression
    }

    /// Builds an element array from an if block
    public static func buildIf(_ content: [any ContextElement]?) -> [any ContextElement] {
        content ?? []
    }

    /// Builds an element array from an if-else block (first branch)
    public static func buildEither(first component: [any ContextElement]) -> [any ContextElement] {
        component
    }

    /// Builds an element array from an if-else block (second branch)
    public static func buildEither(second component: [any ContextElement]) -> [any ContextElement] {
        component
    }

    /// Builds an element array from a for loop
    public static func buildArray(_ components: [[any ContextElement]]) -> [any ContextElement] {
        components.flatMap { $0 }
    }

    /// Builds the final element array
    public static func buildFinalBlock(_ component: [any ContextElement]) -> [any ContextElement] {
        component
    }
}

// MARK: - ContextBlock Convenience Initializer

extension ContextBlock {
    /// Initializes a new context block using a result builder
    /// - Parameters:
    ///   - blockID: An optional identifier for the block
    ///   - builder: A result builder closure that provides the elements
    public init(
        blockID: String? = nil,
        @ContextBuilder builder: () -> [any ContextElement]
    ) {
        self.elements = builder()
        self.blockID = blockID
    }
}
