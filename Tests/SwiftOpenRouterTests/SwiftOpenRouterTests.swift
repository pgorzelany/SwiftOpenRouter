import Testing
@testable import SwiftOpenRouter
import XCTest

@Test func example() async throws {
    #warning("Put api key here")
    let apiKey = ""
    guard !apiKey.isEmpty else { throw XCTSkip("API key not provided.") }
    let client = OpenRouterClient(apiKey: apiKey)
    let streamingClient = OpenRouterStreamingClient(apiKey: apiKey)
    let models = try await client.getAvailableModels()
    #expect(!models.data.isEmpty)
    let credits = try await client.getCredits()
    #expect(credits.data.outstandingCredits > -1000) // Check if outstanding credits value is plausible (allow negative)
    let completion = try await client.getChatCompletion(request: .init(model: "openai/gpt-4o-mini", messages: [.init(role: .user, content: "hey, wassup?")]))
    #expect(!(completion.choices.first?.message.content ?? "").isEmpty)
    print("Streaming output:")
    let streamingCompletion = try await streamingClient.streamChatCompletion(request: .init(model: "openai/gpt-4o-mini", messages: [.init(role: .user, content: "hey, wassup?")]))
    for try await chunk in streamingCompletion {
        print(chunk.choices.first?.delta.content ?? "", terminator: "")
    }
    print("\nStream finished.")
    print("OK")
}
