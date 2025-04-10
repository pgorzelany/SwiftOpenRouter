# SwiftOpenRouter

A Swift wrapper for the [OpenRouter API](https://openrouter.ai).

## Installation

SwiftOpenRouter uses Swift Package Manager for dependency management. Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/pgorzelany/SwiftOpenRouter.git", .upToNextMajor(from: "1.0.0"))
]
```

And add `SwiftOpenRouter` to your target's dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SwiftOpenRouter"]),
]
```

## Usage

### Initializing the Client

First, import `SwiftOpenRouter` and initialize the client with your OpenRouter API key:

```swift
import SwiftOpenRouter

let client = OpenRouterClient(apiKey: "YOUR_API_KEY") 
```

### Fetching Available Models

You can fetch the list of available models:

```swift
do {
    let response = try await client.getAvailableModels()
    print("Available models:")
    for model in response.data {
        print("- \(model.id)")
    }
} catch {
    print("Error fetching models: \(error)")
}
```

### Getting Chat Completions

To get a chat completion:

```swift
import SwiftOpenRouter


let request = ChatCompletionRequest(
    model: "openai/gpt-4o-mini",
    messages: [
        ChatRequestMessage(role: .user, content: "Hello!")
    ]
)

do {
    let response = try await client.getChatCompletion(request: request)
    if let firstChoice = response.choices.first {
        print("Response: \(firstChoice.message.content)")
    }
} catch {
    print("Error getting chat completion: \(error)")
}
```

### Streaming Chat Completions

For streaming responses:

```swift
import SwiftOpenRouter

let request = ChatCompletionRequest(
    model: "openai/gpt-4o-mini", // Example model
    messages: [
        ChatRequestMessage(role: .user, content: "Tell me a short story.")
    ],
    stream: true // Ensure stream is set to true
)

do {
    let stream = try await client.streamChatCompletion(request: request)
    print("Streaming response:")
    for try await chunk in stream {
        if let content = chunk.choices.first?.delta.content {
            print(content, terminator: "")
        }
    }
    print("\nStream finished.")
} catch {
    print("Error streaming chat completion: \(error)")
}

// Example of how to stop streaming manually if needed
Task { await client.stopStreaming() } 
```

### Checking Credits

You can check your remaining credits:

```swift
do {
    let response = try await client.getCredits()
    print("Credits remaining: \(response.credits)")
} catch {
    print("Error fetching credits: \(error)")
}
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License
