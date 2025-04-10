//
//  ChatCompletionResponse.swift
//  SwiftOpenRouter
//
//  Created by Piotr Gorzelany on 20/03/2025.
//

public struct ChatCompletionResponse: Decodable, Sendable {

    public struct Choice: Decodable, Sendable {
        public let logprobs: String?
        public let finishReason: String
        public let nativeFinishReason: String
        public let index: Int
        public let message: OpenRouterChatMessage

        enum CodingKeys: String, CodingKey {
            case logprobs
            case finishReason = "finish_reason"
            case nativeFinishReason = "native_finish_reason"
            case index
            case message
        }
    }

    public struct Usage: Decodable, Sendable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case provider
        case model
        case object
        case created
        case choices
        case usage
    }

    public let id: String
    public let provider: String
    public let model: String
    public let object: String
    public let created: Int
    public let choices: [Choice]
    public let usage: Usage

    public init(
        id: String,
        provider: String,
        model: String,
        object: String,
        created: Int,
        choices: [Choice],
        usage: Usage
    ) {
        self.id = id
        self.provider = provider
        self.model = model
        self.object = object
        self.created = created
        self.choices = choices
        self.usage = usage
    }
}

