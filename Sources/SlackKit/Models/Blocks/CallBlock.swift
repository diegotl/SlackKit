import Foundation

// MARK: - CallBlock

/// A call block for displaying call information
public struct CallBlock: Block {
    public internal(set) var type: BlockType = .call
    public var blockID: String?

    /// The call ID
    public var callID: String

    /// An optional API call ID for use with the Calls API
    public var apiCallID: String?

    /// An optional call object
    public var call: CallObject?

    /// Initializes a new call block
    /// - Parameters:
    ///   - callID: The call ID
    ///   - apiCallID: An optional API call ID
    ///   - call: An optional call object
    ///   - blockID: An optional identifier for the block
    public init(
        callID: String,
        apiCallID: String? = nil,
        call: CallObject? = nil,
        blockID: String? = nil
    ) {
        self.callID = callID
        self.apiCallID = apiCallID
        self.call = call
        self.blockID = blockID
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case blockID = "block_id"
        case callID = "call_id"
        case apiCallID = "api_call_id"
        case call
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BlockType.self, forKey: .type)
        blockID = try container.decodeIfPresent(String.self, forKey: .blockID)
        callID = try container.decode(String.self, forKey: .callID)
        apiCallID = try container.decodeIfPresent(String.self, forKey: .apiCallID)
        call = try container.decodeIfPresent(CallObject.self, forKey: .call)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(blockID, forKey: .blockID)
        try container.encode(callID, forKey: .callID)
        try container.encodeIfPresent(apiCallID, forKey: .apiCallID)
        try container.encodeIfPresent(call, forKey: .call)
    }
}

// MARK: - CallObject

/// Information about a call
public struct CallObject: Codable, Sendable {
    /// An optional call object
    public var callObject: CallInfo?

    public init(callObject: CallInfo? = nil) {
        self.callObject = callObject
    }

    enum CodingKeys: String, CodingKey {
        case callObject = "call"
    }
}

// MARK: - CallInfo

/// Detailed call information
public struct CallInfo: Codable, Sendable {
    /// Unique ID for the call
    public var id: String

    /// The app ID that created the call
    public var appID: String?

    /// The ID of the user who created the call
    public var createdBy: String?

    /// The date and time when the call was created
    public var dateStart: Int?

    /// Whether the call has been ended
    public var hasEnded: Bool?

    /// The ID for the desktop app join URL
    public var desktopAppJoinURL: String?

    /// The call participants
    public var participants: [CallParticipant]?

    /// External unique ID for the call
    public var externalID: String?

    /// The title of the call
    public var title: String?

    /// A list of recordings from the call
    public var recordings: [CallRecording]?

    /// A list of channels the call was displayed in
    public var channels: [String]?

    /// Whether the call is a huddle
    public var isHuddle: Bool?

    public init(
        id: String,
        appID: String? = nil,
        createdBy: String? = nil,
        dateStart: Int? = nil,
        hasEnded: Bool? = nil,
        desktopAppJoinURL: String? = nil,
        participants: [CallParticipant]? = nil,
        externalID: String? = nil,
        title: String? = nil,
        recordings: [CallRecording]? = nil,
        channels: [String]? = nil,
        isHuddle: Bool? = nil
    ) {
        self.id = id
        self.appID = appID
        self.createdBy = createdBy
        self.dateStart = dateStart
        self.hasEnded = hasEnded
        self.desktopAppJoinURL = desktopAppJoinURL
        self.participants = participants
        self.externalID = externalID
        self.title = title
        self.recordings = recordings
        self.channels = channels
        self.isHuddle = isHuddle
    }

    enum CodingKeys: String, CodingKey {
        case id
        case appID = "app_id"
        case createdBy = "created_by"
        case dateStart = "date_start"
        case hasEnded = "has_ended"
        case desktopAppJoinURL = "desktop_app_join_url"
        case participants
        case externalID = "external_unique_id"
        case title, recordings, channels
        case isHuddle = "is_a_huddle"
    }
}

// MARK: - CallParticipant

/// A call participant
public struct CallParticipant: Codable, Sendable {
    /// The Slack ID of the participant
    public var slackID: String

    /// External ID for the participant
    public var externalID: String?

    /// The avatar URL for the participant
    public var avatarURL: String?

    /// The display name for the participant
    public var displayName: String?

    public init(
        slackID: String,
        externalID: String? = nil,
        avatarURL: String? = nil,
        displayName: String? = nil
    ) {
        self.slackID = slackID
        self.externalID = externalID
        self.avatarURL = avatarURL
        self.displayName = displayName
    }

    enum CodingKeys: String, CodingKey {
        case slackID = "slack_id"
        case externalID = "external_id"
        case avatarURL = "avatar_url"
        case displayName = "display_name"
    }
}

// MARK: - CallRecording

/// A recording from a call
public struct CallRecording: Codable, Sendable {
    /// The title of the recording
    public var title: String

    /// The URL of the recording
    public var url: String

    /// The ID of the recording
    public var id: String?

    /// The duration of the recording
    public var duration: Int?

    public init(
        title: String,
        url: String,
        id: String? = nil,
        duration: Int? = nil
    ) {
        self.title = title
        self.url = url
        self.id = id
        self.duration = duration
    }
}
