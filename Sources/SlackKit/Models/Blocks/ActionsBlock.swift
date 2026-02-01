import Foundation

// MARK: - ActionsBlock

/// An actions block that contains interactive elements
public struct ActionsBlock: Block {
    public internal(set) var type: BlockType = .actions
    public var blockID: String?

    /// The interactive elements (1-25 elements)
    @AnyBlockElementArrayCodable public var elements: [any BlockElement]

    /// Initializes a new actions block
    /// - Parameters:
    ///   - elements: The interactive elements (1-25 elements)
    ///   - blockID: An optional identifier for the block
    public init(
        elements: [any BlockElement],
        blockID: String? = nil
    ) {
        self.elements = elements
        self.blockID = blockID
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case blockID = "block_id"
        case elements
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BlockType.self, forKey: .type)
        blockID = try container.decodeIfPresent(String.self, forKey: .blockID)

        // Decode elements polymorphically
        if var elementsContainer = try? container.nestedUnkeyedContainer(forKey: .elements) {
            var decodedElements: [any BlockElement] = []
            while !elementsContainer.isAtEnd {
                if let element = try? elementsContainer.decode(AnyBlockElement.self) {
                    decodedElements.append(element.value)
                } else {
                    // Skip unknown element types
                    _ = try? elementsContainer.decode(EmptyElement.self)
                }
            }
            elements = decodedElements.isEmpty ? [] : decodedElements
        } else {
            elements = []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(blockID, forKey: .blockID)

        // Encode elements polymorphically
        try container.encode(elements.map { AnyBlockElement($0) }, forKey: .elements)
    }
}

// MARK: - EmptyElement

/// Helper type for decoding unknown element types
private struct EmptyElement: Codable {
    let type: String
}

// MARK: - Property Wrapper for Element Arrays

/// Property wrapper for handling arrays of polymorphic block elements
@propertyWrapper
public struct AnyBlockElementArrayCodable {
    public var wrappedValue: [any BlockElement]

    public init(wrappedValue: [any BlockElement] = []) {
        self.wrappedValue = wrappedValue
    }
}

extension AnyBlockElementArrayCodable: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [any BlockElement] = []

        while !container.isAtEnd {
            if let element = try? container.decode(AnyBlockElement.self) {
                elements.append(element.value)
            } else {
                // Skip unknown element types
                _ = try? container.decode(EmptyElement.self)
            }
        }

        wrappedValue = elements
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in wrappedValue {
            try container.encode(AnyBlockElement(element))
        }
    }
}

extension AnyBlockElementArrayCodable: Sendable {}
