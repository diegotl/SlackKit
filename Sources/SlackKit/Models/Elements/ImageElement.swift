import Foundation

// MARK: - ImageElement

/// An image element that displays an image
public struct ImageElement: BlockElement {
    public let type: String = "image"
    public var imageURL: String
    public var altText: String

    /// Initializes a new image element
    /// - Parameters:
    ///   - imageURL: The URL of the image
    ///   - altText: Alt text for the image
    public init(
        imageURL: String,
        altText: String
    ) {
        self.imageURL = imageURL
        self.altText = altText
    }

    enum CodingKeys: String, CodingKey {
        case type
        case imageURL = "image_url"
        case altText = "alt_text"
    }
}
