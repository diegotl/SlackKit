import Foundation

// MARK: - HeaderBlock

/// A header block is used to display a larger, bold text element
public struct HeaderBlock: Block {
    public internal(set) var type: BlockType = .header
    public var blockID: String?

    /// The text for the header (plain text only, max 150 characters)
    public var text: TextObject

    /// Initializes a new header block
    /// - Parameters:
    ///   - text: The text for the header (plain text only, max 150 characters)
    ///   - blockID: An optional identifier for the block
    public init(
        text: TextObject,
        blockID: String? = nil
    ) {
        self.text = text
        self.blockID = blockID
    }

    /// Convenience initializer with a plain text string
    /// - Parameters:
    ///   - text: The text string for the header
    ///   - blockID: An optional identifier for the block
    public init(
        text: String,
        blockID: String? = nil
    ) {
        self.text = .plainText(text)
        self.blockID = blockID
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case blockID = "block_id"
        case text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BlockType.self, forKey: .type)
        blockID = try container.decodeIfPresent(String.self, forKey: .blockID)
        text = try container.decode(TextObject.self, forKey: .text)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(blockID, forKey: .blockID)
        try container.encode(text, forKey: .text)
    }
}
