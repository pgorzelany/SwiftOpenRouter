//
//  ChatCompletionChunk.swift
//  SwiftOpenRouter
//
//  Created by Piotr Gorzelany on 23/03/2025.
//

import Foundation

public struct ChatCompletionChunk: Decodable, Sendable {
    public let id: String
    public let provider: String
    public let model: String
    public let object: String
    public let created: Date
    public let choices: [Choice]
    public let usage: Usage?

    public struct Choice: Decodable, Sendable {
        public let index: Int
        public let delta: Delta
        public let finishReason: String?
        public let nativeFinishReason: String?

        private enum CodingKeys: String, CodingKey {
            case index, delta
            case finishReason = "finish_reason"
            case nativeFinishReason = "native_finish_reason"
        }
    }

    public struct Delta: Decodable, Sendable {
        public let role: String?
        public let content: String?
    }

    public struct Usage: Decodable, Sendable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int

        private enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}
