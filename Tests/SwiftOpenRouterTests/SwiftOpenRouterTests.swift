import Testing
@testable import SwiftOpenRouter

@Test func example() async throws {
    #warning("Put api key here")
    let apiKey = ""
    let client = OpenRouterClient(apiKey: apiKey)
    let streamingClient = OpenRouterStreamingClient(apiKey: apiKey)
    let models = try await client.getAvailableModels()
    let credits = try await client.getCredits()
    let completion = try await client.getChatCompletion(request: .init(model: "openai/gpt-4o-mini", messages: [.init(role: .user, content: "hey, wassup?")]))
    let streamingCompletion = try await streamingClient.streamChatCompletion(request: .init(model: "openai/gpt-4o-mini", messages: [.init(role: .user, content: "hey, wassup?")], stream: true))
    for try await chunk in streamingCompletion {
        print(chunk.choices.first?.delta.content ?? "")
    }
    print("OK")
}
