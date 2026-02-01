import Foundation

// MARK: - SectionBlock

/// A section block is used to display information in a flexible format
public struct SectionBlock: Block {
    public internal(set) var type: BlockType = .section
    public var blockID: String?

    /// The text for the block
    public var text: TextObject?

    /// An array of text objects (max 5)
    public var fields: [TextObject]?

    /// An accessory element to display
    @AnyBlockElementCodable public var accessory: (any BlockElement)?

    /// Initializes a new section block
    /// - Parameters:
    ///   - text: The text for the block
    ///   - fields: An array of text objects (max 5, max 10 items each)
    ///   - accessory: An accessory element
    ///   - blockID: An optional identifier for the block
    public init(
        text: TextObject? = nil,
        fields: [TextObject]? = nil,
        accessory: (any BlockElement)? = nil,
        blockID: String? = nil
    ) {
        self.text = text
        self.fields = fields
        self.accessory = accessory
        self.blockID = blockID
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case blockID = "block_id"
        case text
        case fields
        case accessory
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BlockType.self, forKey: .type)
        blockID = try container.decodeIfPresent(String.self, forKey: .blockID)
        text = try container.decodeIfPresent(TextObject.self, forKey: .text)
        fields = try container.decodeIfPresent([TextObject].self, forKey: .fields)

        // Decode accessory as AnyBlockElement
        if let accessoryData = try? container.decodeIfPresent(AnyBlockElement.self, forKey: .accessory) {
            accessory = accessoryData.value
        } else {
            accessory = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(blockID, forKey: .blockID)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(fields, forKey: .fields)

        // Encode accessory
        if let accessory = accessory {
            try container.encode(AnyBlockElement(accessory), forKey: .accessory)
        }
    }
}
