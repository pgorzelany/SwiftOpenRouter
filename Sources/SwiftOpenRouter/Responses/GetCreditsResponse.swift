//
//  GetCreditsResponse.swift
//  SwiftOpenRouter
//
//  Created by Piotr Gorzelany on 20/03/2025.
//

import Foundation

public struct OpenRouterCredits: Decodable, Sendable {
    
    enum CodingKeys: String, CodingKey {
        case totalCredits = "total_credits"
        case totalUsage = "total_usage"
    }

    public init(totalCredits: Double, totalUsage: Double) {
        self.totalCredits = totalCredits
        self.totalUsage = totalUsage
    }

    public let totalCredits: Double
    public let totalUsage: Double
    public var outstandingCredits: Double {
        totalCredits - totalUsage
    }
}

public struct GetCreditsResponse: Decodable, Sendable {
    public let data: OpenRouterCredits
}
