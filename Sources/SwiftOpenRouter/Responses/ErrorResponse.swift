//
//  ErrorResponse.swift
//  SwiftOpenRouter
//
//  Created by Piotr Gorzelany on 19/03/2025.
//

public struct OpenRouterErrorResponse: Decodable, Sendable {
    public struct Details: Decodable, Sendable {
        public let code: Int
        public let message: String
    }

    public let error: Details
}
