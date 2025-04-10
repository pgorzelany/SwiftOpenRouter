import Testing
@testable import SwiftOpenRouter
import XCTest
import Foundation

// Define the response structure expected by the API
struct TaskStatusResponse: Decodable, Sendable {
    let status: TaskStatus
}

// Add conformance to JSONSchemaConvertible for TaskStatusResponse
extension TaskStatusResponse: JSONSchemaConvertible {
    static func jsonSchema() -> JSONSchemaDefinition {
        // Define the object schema with a 'status' property using TaskStatus's schema
        .object(
            description: "Wrapper object for task status.",
            properties: [
                "status": TaskStatus.schemaDefinition // Reference the schema from the original TaskStatus
            ],
            required: ["status"]
        )
    }
}

struct StructuredOutputAPITests {
    
    private let apiKey: String
    private let client: OpenRouterClient

    init() {
        if let key = ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"], !key.isEmpty {
            self.apiKey = key
        } else {
            #warning("API key not set: Set OPENROUTER_API_KEY environment variable for API tests.")
            self.apiKey = ""
        }
        self.client = OpenRouterClient(apiKey: self.apiKey)
    }

    @Test func testStructuredOutputAPI() async throws {
        // try skipIfAPIKeyMissing()
        
        let request = ChatCompletionRequest(
            model: "openai/gpt-4o",
            messages: [
                .init(role: .system, content: "You are a helpful assistant that provides weather information in JSON format according to the schema derived from the WeatherResponse type."),
                .init(role: .user, content: "What is the weather like in Tokyo?")
            ]
        )

        let weatherData: WeatherResponse = try await client.getChatCompletion(
            request: request,
            responseType: WeatherResponse.self
        )

        print("Decoded Weather Data: \(weatherData)")

        #expect(!weatherData.location.isEmpty)
        #expect(weatherData.location.lowercased().contains("tokyo"))
        #expect(["celsius", "fahrenheit"].contains(weatherData.unit))
    }

    @Test func testStructuredOutputAPIEnum() async throws {
        // try skipIfAPIKeyMissing()
        
        let request = ChatCompletionRequest(
            model: "openai/gpt-4o",
            messages: [
                .init(role: .system, content: "You are an assistant that determines task status. Respond with *only* one of the following strings based on the user query: PENDING, PROCESSING, COMPLETED, FAILED, wrapped in a JSON object with a 'status' key, according to the schema derived from the TaskStatusResponse type."),
                .init(role: .user, content: "The report generation is still running.")
            ]
        )

        let response: TaskStatusResponse = try await client.getChatCompletion(
            request: request,
            responseType: TaskStatusResponse.self
        )

        print("Decoded Task Status Response: \(response)")
        print("Status: \(response.status)")

        #expect(TaskStatus.allCases.contains(response.status))
    }
} 
