//
//  OpenRouterChatMessage.swift
//  SwiftOpenRouter
//
//  Created by Piotr Gorzelany on 20/03/2025.
//

public struct OpenRouterChatMessage: Codable, Sendable {
    public enum Role: String, Codable, Sendable {
        case user
        case assistant
        case system
        case tool
    }

    public let role: Role
    public let content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}
