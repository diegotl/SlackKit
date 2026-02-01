import Foundation

// MARK: - ImageBlock

/// An image block for displaying images
public struct ImageBlock: Block {
    public internal(set) var type: BlockType = .image
    public var blockID: String?

    /// The URL of the image
    public var imageURL: URL

    /// Alt text for the image
    public var altText: String

    /// An optional title
    public var title: TextObject?

    /// Initializes a new image block
    /// - Parameters:
    ///   - imageURL: The URL of the image
    ///   - altText: Alt text for the image
    ///   - title: An optional title
    ///   - blockID: An optional identifier for the block
    public init(
        imageURL: URL,
        altText: String,
        title: TextObject? = nil,
        blockID: String? = nil
    ) {
        self.imageURL = imageURL
        self.altText = altText
        self.title = title
        self.blockID = blockID
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case blockID = "block_id"
        case imageURL = "image_url"
        case altText = "alt_text"
        case title
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BlockType.self, forKey: .type)
        blockID = try container.decodeIfPresent(String.self, forKey: .blockID)

        // Decode URL from string
        let urlString = try container.decode(String.self, forKey: .imageURL)
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .imageURL,
                in: container,
                debugDescription: "Invalid URL string"
            )
        }
        imageURL = url

        altText = try container.decode(String.self, forKey: .altText)
        title = try container.decodeIfPresent(TextObject.self, forKey: .title)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(blockID, forKey: .blockID)
        try container.encode(imageURL.absoluteString, forKey: .imageURL)
        try container.encode(altText, forKey: .altText)
        try container.encodeIfPresent(title, forKey: .title)
    }
}
