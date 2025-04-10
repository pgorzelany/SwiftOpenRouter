import Testing
@testable import SwiftOpenRouter
import XCTest
import Foundation

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

        do {
            let weatherData: WeatherResponse = try await client.getChatCompletion(
                request: request,
                responseType: WeatherResponse.self
            )
            
            print("Decoded Weather Data: \(weatherData)")
            
            #expect(!weatherData.location.isEmpty)
            #expect(weatherData.location.lowercased().contains("tokyo"))
            #expect(["celsius", "fahrenheit"].contains(weatherData.unit))

        } catch {
            XCTFail("Failed to get typed chat completion: \(error)")
        }
    }

    @Test func testStructuredOutputAPIEnum() async throws {
        // try skipIfAPIKeyMissing()
        
        let request = ChatCompletionRequest(
            model: "openai/gpt-4o",
            messages: [
                .init(role: .system, content: "You are an assistant that determines task status. Respond with *only* one of the following strings based on the user query: PENDING, PROCESSING, COMPLETED, FAILED. The response must exactly match the schema derived from the TaskStatus enum."),
                .init(role: .user, content: "The report generation is still running.")
            ]
        )

        do {
            let status: TaskStatus = try await client.getChatCompletion(
                request: request,
                responseType: TaskStatus.self
            )

            print("Decoded Task Status: \(status)")

            #expect(TaskStatus.allCases.contains(status))

        } catch {
            XCTFail("Failed to get typed enum chat completion: \(error)")
        }
    }
} 