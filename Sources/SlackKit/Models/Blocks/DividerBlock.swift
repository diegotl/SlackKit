import Foundation

// MARK: - DividerBlock

/// A content divider that creates a horizontal line
public struct DividerBlock: Block {
    public internal(set) var type: BlockType = .divider
    public var blockID: String?

    /// Initializes a new divider block
    /// - Parameter blockID: An optional identifier for the block
    public init(blockID: String? = nil) {
        self.blockID = blockID
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case blockID = "block_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BlockType.self, forKey: .type)
        blockID = try container.decodeIfPresent(String.self, forKey: .blockID)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(blockID, forKey: .blockID)
    }
}
