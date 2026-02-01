import Foundation

// MARK: - ContextBlock

/// A context block for displaying contextual information
public struct ContextBlock: Block {
    public internal(set) var type: BlockType = .context
    public var blockID: String?

    /// The context elements (text and images)
    @AnyContextElementArrayCodable public var elements: [any ContextElement]

    /// Initializes a new context block
    /// - Parameters:
    ///   - elements: The context elements (1-10 elements)
    ///   - blockID: An optional identifier for the block
    public init(
        elements: [any ContextElement],
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
            var decodedElements: [any ContextElement] = []
            while !elementsContainer.isAtEnd {
                if let element = try? elementsContainer.decode(AnyContextElement.self) {
                    decodedElements.append(element.value)
                } else {
                    // Skip unknown element types
                    _ = try? elementsContainer.decode(EmptyContextElement.self)
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
        try container.encode(elements.map { AnyContextElement($0) }, forKey: .elements)
    }
}

// MARK: - ContextElement Protocol

/// A protocol defining context elements
public protocol ContextElement: BlockElement {}

// MARK: - TextContextElement

/// A text element for context blocks
public struct TextContextElement: ContextElement {
    public let type: String = "plain_text"
    public var text: String

    public init(text: String) {
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case type, text
    }
}

// MARK: - ImageContextElement

/// An image element for context blocks
public struct ImageContextElement: ContextElement {
    public let type: String = "image"
    public var imageURL: String
    public var altText: String

    public init(imageURL: String, altText: String) {
        self.imageURL = imageURL
        self.altText = altText
    }

    enum CodingKeys: String, CodingKey {
        case type
        case imageURL = "image_url"
        case altText = "alt_text"
    }
}

// MARK: - AnyContextElement

/// Type erasure wrapper for encoding context elements
public struct AnyContextElement: Codable, Sendable {
    public let value: any ContextElement

    public init(_ value: any ContextElement) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "plain_text", "mrkdwn":
            self.value = try TextContextElement(from: decoder)
        case "image":
            self.value = try ImageContextElement(from: decoder)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported context element type: \(type)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        // ContextElement conforms to Codable, so value is Encodable
        // Cast to Encodable to call encode on the existential type
        try (value as Encodable).encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: - EmptyContextElement

/// Helper type for decoding unknown context element types
private struct EmptyContextElement: Codable {
    let type: String
}

// MARK: - Property Wrapper for Context Element Arrays

/// Property wrapper for handling arrays of polymorphic context elements
@propertyWrapper
public struct AnyContextElementArrayCodable {
    public var wrappedValue: [any ContextElement]

    public init(wrappedValue: [any ContextElement] = []) {
        self.wrappedValue = wrappedValue
    }
}

extension AnyContextElementArrayCodable: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [any ContextElement] = []

        while !container.isAtEnd {
            if let element = try? container.decode(AnyContextElement.self) {
                elements.append(element.value)
            } else {
                // Skip unknown element types
                _ = try? container.decode(EmptyContextElement.self)
            }
        }

        wrappedValue = elements
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in wrappedValue {
            try container.encode(AnyContextElement(element))
        }
    }
}

extension AnyContextElementArrayCodable: Sendable {}
