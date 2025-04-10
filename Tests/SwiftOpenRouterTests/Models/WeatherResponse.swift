import Foundation
@testable import SwiftOpenRouter

struct WeatherResponse: Decodable, Equatable, JSONSchemaConvertible {
    let location: String
    let temperature: Double
    let unit: String

    static func jsonSchema() -> JSONSchemaDefinition {
        .object(
            description: "Weather information for a location",
            properties: [
                "location": .string(description: "The city and state, e.g. San Francisco, CA"),
                "temperature": .number(description: "The temperature in the specified unit"),
                "unit": .enum(description: "The unit for the temperature", values: [.string("celsius"), .string("fahrenheit")])
            ],
            required: ["location", "temperature", "unit"]
        )
    }
} 
