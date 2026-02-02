# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Testing
```bash
swift build              # Build the package
swift test               # Run all tests
swift test --filter <name>  # Run specific test (e.g., "sendMessage")
```

### Git Commits

Commit messages should be short and concise, multi-line is acceptable. Describe all changes made.

Example format:
```
Center logo and add badges. Update CLAUDE commit guide.
```

### Platform Requirements
- macOS 12.0+, iOS 15.0+, tvOS 15.0+, watchOS 8.0+
- Swift 6.0+ with strict concurrency enabled

## Architecture Overview

SlackKit is a Swift package for sending messages to Slack via Incoming Webhooks with full Block Kit support. The architecture uses a layered design with protocol-based networking and polymorphic Codable encoding.

### Core Abstractions

**Network Layer** (`Sources/SlackKit/Client/`)
- `NetworkClient` protocol: Abstracts HTTP operations for testability
- `URLSessionNetworkClient` actor: Default URLSession-based implementation
- `SlackWebhookClient` actor: Main client that composes network layer with message encoding

**Model Layer** (`Sources/SlackKit/Models/`)
- `Message`: Container for webhook messages, supports text, blocks, attachments, and mrkdwn control
- `Block` protocol: Base protocol for all Block Kit layout types (Section, Divider, Image, Actions, Context, Header, Input, Call)
- `BlockElement` protocol: Base protocol for interactive elements within blocks
- `TextObject` enum: Polymorphic type for plain text vs markdown

**Element Types** (`Sources/SlackKit/Models/Elements/`)
- `ButtonElement`: Clickable buttons with styles
- `StaticSelectElement` / `ExternalSelectElement`: Single-select menus
- `MultiStaticSelectElement`, `MultiExternalSelectElement`, `MultiUsersSelectElement`, `MultiConversationsSelectElement`, `MultiChannelsSelectElement`: Multi-select menus
- `DatePickerElement`: Date selection
- `UsersSelectElement`, `ConversationsSelectElement`, `ChannelsSelectElement`: Specialized selectors
- `OverflowElement`: Overflow menus

### Polymorphic Codable Pattern

The library uses sophisticated polymorphic encoding to handle Slack's flexible block/element types:

**Type Erasure Wrappers:**
- `AnyBlock` (private): Wraps blocks for encoding in Message
- `AnyBlockElement`: Public wrapper for encoding/decoding any BlockElement
- `AnyContextElement`: Similar wrapper for ContextBlock elements

**Property Wrappers:**
- `@AnyBlockElementCodable`: For single optional BlockElement properties
- `@AnyBlockElementArrayCodable`: For arrays of BlockElement
- `@AnyContextElementArrayCodable`: For arrays of ContextElement

These wrappers handle the complex decoding logic by trying known types sequentially and gracefully skipping unknown types for forward compatibility.

### Adding New Block Types

When adding a new Slack block type:

1. Create struct in `Sources/SlackKit/Models/Blocks/`
2. Conform to `Block` protocol with:
   - `public internal(set) var type: BlockType = .yourType` (must be `var` for Codable)
   - Optional `blockID: String?` property
3. Custom `init(from decoder:)` if containing polymorphic elements
4. Add the BlockType case to `Models/Block.swift`
5. Add to `Message.init(from decoder:)` polymorphic decoding list
6. Add to `AnyBlockElement.init(from decoder:)` if it can be an accessory

### Adding New Element Types

When adding a new interactive element:

1. Create struct in `Sources/SlackKit/Models/Elements/`
2. Conform to `BlockElement` protocol with:
   - `public let type: String = "element_type"` (constant is fine for elements)
3. Add to `AnyBlockElement.init(from decoder:)` decoding list
4. Add to `InputBlock.init(from decoder:)` if it can be used in InputBlock

### Important Implementation Notes

**Attachment Parameter Order:** When initializing `Attachment`, the parameter order is: `fallback`, `color`, `pretext`, `authorName`, `authorLink`, `authorIcon`, `title`, `titleLink`, `text`, `fields`, `imageURL`, `thumbURL`, `footer`, `footerIcon`, `footerTimestamp`, `blocks`. Note that `color` comes before `title`.

**InputBlock Codable:** `InputBlock.element` is `any BlockElement`, which cannot be automatically synthesized. Use custom `init(from decoder:)` that decodes element type polymorphically and encodes with a cast to `Encodable`.

**Multi-Select Protocols:** `MultiSelectElement` protocol defines common properties, but each multi-select type has its own initial value property (e.g., `initialUsers`, `initialConversations`, `initialChannels`).

**Conversation Filter:** Used with `ConversationsSelectElement` and `MultiConversationsSelectElement` to filter which conversation types are included.

### Swift 6 Concurrency

- `SlackWebhookClient` and `URLSessionNetworkClient` are actors for thread-safe mutable state
- All public types conform to `Sendable`
- Use `await` when calling actor-isolated methods (e.g., MockNetworkClient in tests)

### Key Implementation Details

**Message Encoding:** The `Message` struct's `encode(to:)` method manually encodes blocks using `AnyBlock` wrapper since Codable can't handle existential arrays directly.

**Block Type Properties:** All block structs use `public internal(set) var type` instead of `let` because the default value gets overwritten during decoding.

**Unknown Types:** During decoding, unknown block/element types are silently skipped by attempting to decode into throwaway wrapper types (`BlockWrapper`, `EmptyElement`).

**Error Wrapping:** Network clients always wrap underlying errors in `SlackError.networkError` - check MockNetworkClient for the pattern.

### Testing

Tests use Swift Testing framework. Key patterns:
- Use `await` with `MockNetworkClient` methods (it's an actor)
- Access actor state with `let requests = await mockClient.requests`
- Mock uses `Result<HTTPResponse, Error>` queue for sequencing responses

### Slack API Reference

- [Block Kit](https://api.slack.com/block-kit)
- [Incoming Webhooks](https://api.slack.com/messaging/webhooks)
