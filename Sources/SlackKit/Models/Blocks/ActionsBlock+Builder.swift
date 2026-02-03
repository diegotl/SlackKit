import Foundation

// MARK: - ActionsBuilder

/// A result builder for constructing ActionsBlock elements
@resultBuilder
public enum ActionsBuilder {
    /// Builds an empty element array
    public static func buildBlock() -> [any BlockElement] {
        []
    }

    /// Builds an element array from multiple elements
    public static func buildBlock(_ components: [any BlockElement]...) -> [any BlockElement] {
        components.flatMap { $0 }
    }

    /// Builds an element array from a single element expression
    public static func buildExpression(_ expression: any BlockElement) -> [any BlockElement] {
        [expression]
    }

    /// Builds an element array from an optional element expression
    public static func buildExpression(_ expression: (any BlockElement)?) -> [any BlockElement] {
        expression.map { [$0] } ?? []
    }

    /// Builds an element array from an array of elements (pass-through)
    public static func buildExpression(_ expression: [any BlockElement]) -> [any BlockElement] {
        expression
    }

    /// Builds an element array from an if block
    public static func buildIf(_ content: [any BlockElement]?) -> [any BlockElement] {
        content ?? []
    }

    /// Builds an element array from an if-else block (first branch)
    public static func buildEither(first component: [any BlockElement]) -> [any BlockElement] {
        component
    }

    /// Builds an element array from an if-else block (second branch)
    public static func buildEither(second component: [any BlockElement]) -> [any BlockElement] {
        component
    }

    /// Builds an element array from a for loop
    public static func buildArray(_ components: [[any BlockElement]]) -> [any BlockElement] {
        components.flatMap { $0 }
    }

    /// Builds the final element array
    public static func buildFinalBlock(_ component: [any BlockElement]) -> [any BlockElement] {
        component
    }
}

// MARK: - ActionsBlock Convenience Initializer

extension ActionsBlock {
    /// Initializes a new actions block using a result builder
    /// - Parameters:
    ///   - blockID: An optional identifier for the block
    ///   - builder: A result builder closure that provides the elements
    public init(
        blockID: String? = nil,
        @ActionsBuilder builder: () -> [any BlockElement]
    ) {
        self.elements = builder()
        self.blockID = blockID
    }
}
