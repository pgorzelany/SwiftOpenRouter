//
//  OpenRouterRequest.swift
//  SwiftOpenRouter
//
//  Created by Piotr Gorzelany on 19/03/2025.
//

import Foundation

struct OpenRouterRequest {
    let method: HTTPMethod
    let url: URL
    let body: Encodable?
    let headers: [String: String]
}
