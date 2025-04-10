import Foundation

public struct OpenRouterModel: Decodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case created
        case description
        case contextLength = "context_length"
        case architecture
        case topProvider = "top_provider"
        case pricing
        case perRequestLimits = "per_request_limits"
    }

    public let id: String
    public let name: String
    public let created: Date
    public let description: String
    public let contextLength: Int
    public let architecture: Architecture
    public let topProvider: TopProvider
    public let pricing: Pricing
    public let perRequestLimits: [String: String]?

    public struct Architecture: Decodable, Sendable {
        public let modality: String
        public let tokenizer: String
    }

    public struct TopProvider: Decodable, Sendable {
        enum CodingKeys: String, CodingKey {
            case contextLength = "context_length"
            case maxCompletionTokens = "max_completion_tokens"
            case isModerated = "is_moderated"
        }

        public let contextLength: Int?
        public let maxCompletionTokens: Int?
        public let isModerated: Bool
    }

    public struct Pricing: Decodable, Sendable {
        enum CodingKeys: String, CodingKey {
            case prompt
            case completion
            case image
            case request
            case inputCacheRead = "input_cache_read"
            case inputCacheWrite = "input_cache_write"
            case webSearch = "web_search"
            case internalReasoning = "internal_reasoning"
        }

        public let prompt: Decimal
        public let completion: Decimal
        public let image: Decimal
        public let request: Decimal
        public let inputCacheRead: Decimal
        public let inputCacheWrite: Decimal
        public let webSearch: Decimal
        public let internalReasoning: Decimal
    }
}

public struct ListAvailableModelsResponse: Decodable, Sendable {
    public let data: [OpenRouterModel]
}
