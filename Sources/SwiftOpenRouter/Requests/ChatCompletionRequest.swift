//
//  ChatCompletionRequest.swift
//  SwiftOpenRouter
//
//  Created by Piotr Gorzelany on 20/03/2025.
//

public struct ChatCompletionRequest: Encodable, Sendable {

    public struct Provider: Encodable, Sendable {
        public let sort: String?
    }

    public struct Reasoning: Encodable, Sendable {
        public enum Effort: String, Encodable, Sendable {
            case high
            case medium
            case low
        }

        enum CodingKeys: String, CodingKey {
            case effort
            case maxTokens = "max_tokens"
            case exclude
        }

        public let effort: Effort?
        public let maxTokens: Int?
        public let exclude: Bool?
    }

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case stream
        case maxTokens = "max_tokens"
        case temperature
        case seed
        case topP = "top_p"
        case topK = "top_k"
        case frequencyPenalty = "frequency_penalty"
        case presencePenalty = "presence_penalty"
        case repetitionPenalty = "repetition_penalty"
        case logitBias = "logit_bias"
        case topLogprobs = "top_logprobs"
        case minP = "min_p"
        case topA = "top_a"
        case transforms
        case models
        case route
        case provider
        case reasoning
        case responseFormat = "response_format"
    }

    public let model: String
    public let messages: [OpenRouterChatMessage]
    public let stream: Bool?
    public let maxTokens: Int?
    public let temperature: Double?
    public let seed: Int?
    public let topP: Double?
    public let topK: Int?
    public let frequencyPenalty: Double?
    public let presencePenalty: Double?
    public let repetitionPenalty: Double?
    public let logitBias: [String: Double]?
    public let topLogprobs: Int?
    public let minP: Double?
    public let topA: Double?
    public let transforms: [String]?
    public let models: [String]?
    public let route: String?
    public let provider: Provider?
    public let reasoning: Reasoning?
    public let responseFormat: ResponseFormat?

    public init(
        model: String,
        messages: [OpenRouterChatMessage],
        stream: Bool? = nil,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        seed: Int? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        frequencyPenalty: Double? = nil,
        presencePenalty: Double? = nil,
        repetitionPenalty: Double? = nil,
        logitBias: [String: Double]? = nil,
        topLogprobs: Int? = nil,
        minP: Double? = nil,
        topA: Double? = nil,
        transforms: [String]? = nil,
        models: [String]? = nil,
        route: String? = nil,
        provider: Provider? = nil,
        reasoning: Reasoning? = nil,
        responseFormat: ResponseFormat? = nil
    ) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.seed = seed
        self.topP = topP
        self.topK = topK
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.repetitionPenalty = repetitionPenalty
        self.logitBias = logitBias
        self.topLogprobs = topLogprobs
        self.minP = minP
        self.topA = topA
        self.transforms = transforms
        self.models = models
        self.route = route
        self.provider = provider
        self.reasoning = reasoning
        self.responseFormat = responseFormat
    }
}

/// Represents the structured output format specification.
/// See: https://openrouter.ai/docs/features/structured-outputs
public struct ResponseFormat: Encodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }
    /// Must be "json_schema".
    public let type: String
    public let jsonSchema: JSONSchema

    /// Initializes a ResponseFormat for JSON schema validation.
    /// - Parameter jsonSchema: The JSON schema definition wrapper.
    public init(jsonSchema: JSONSchema) {
        self.type = "json_schema"
        self.jsonSchema = jsonSchema
    }
}


