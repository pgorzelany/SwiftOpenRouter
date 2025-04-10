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

### Structured Output (JSON Mode)

You can request the model to output JSON conforming to a specific structure defined by your Swift types. This is useful for ensuring the model's response can be reliably decoded into your application's data models.

To use this feature, your desired response type must conform to `Decodable`, `Sendable`, and `SwiftOpenRouter.JSONSchemaConvertible`.

The `JSONSchemaConvertible` protocol requires you to implement a static function `jsonSchema()` that returns a `JSONSchemaDefinition` describing the structure of your type. The library uses this to automatically generate the `response_format` needed by the API.

**Example 1: Fetching Structured Weather Data**

First, define your Swift struct and make it conform:

```swift
import SwiftOpenRouter

// 1. Define your response structure
struct WeatherResponse: Decodable, Sendable {
    let location: String
    let temperature: Double
    let unit: String // "celsius" or "fahrenheit"
    let description: String
}

// 2. Conform to JSONSchemaConvertible
extension WeatherResponse: JSONSchemaConvertible {
    static func jsonSchema() -> JSONSchemaDefinition {
        .object(
            properties: [
                "location": .string(description: "The city and state, e.g., San Francisco, CA"),
                "temperature": .number(description: "The current temperature"),
                "unit": .enum(description: "Temperature unit", values: [.string("celsius"), .string("fahrenheit")]),
                "description": .string(description: "A brief description of the weather")
            ],
            required: ["location", "temperature", "unit", "description"]
        )
    }
}
```

Then, call `getChatCompletion` specifying the `responseType`:

```swift
let request = ChatCompletionRequest(
    model: "openai/gpt-4o", // Or any model supporting JSON mode
    messages: [
        .init(role: .system, content: "You are a helpful assistant that provides weather information in JSON format according to the schema derived from the WeatherResponse type."),
        .init(role: .user, content: "What is the weather like in Toronto?")
    ]
)

do {
    // 3. Call getChatCompletion with the responseType
    let weatherData: WeatherResponse = try await client.getChatCompletion(
        request: request,
        responseType: WeatherResponse.self // Pass your type here
    )
    print("Weather in \(weatherData.location): \(weatherData.temperature)°\(weatherData.unit == "celsius" ? "C" : "F"), \(weatherData.description)")
} catch {
    print("Error getting structured chat completion: \(error)")
}
```

**Example 2: Fetching an Enum Status (Requires Object Wrapper)**

The API's JSON Schema mode requires the root schema to be an object. If you want to get a simple enum value, you need to wrap it in a struct.

```swift
import SwiftOpenRouter

// 1. Define the Enum (conformance provided by default extension)
enum TaskStatus: String, Decodable, Sendable, CaseIterable {
    case PENDING, PROCESSING, COMPLETED, FAILED
}
// Note: JSONSchemaConvertible conformance for RawRepresentable & CaseIterable enums
// is often provided automatically by the library.

// 2. Define the wrapper struct required by the API
struct TaskStatusResponse: Decodable, Sendable {
    let status: TaskStatus
}

// 3. Conform the wrapper struct to JSONSchemaConvertible
extension TaskStatusResponse: JSONSchemaConvertible {
    static func jsonSchema() -> JSONSchemaDefinition {
        .object(
            description: "Response containing the task status.",
            properties: [
                // Use the schema automatically derived for TaskStatus
                "status": TaskStatus.jsonSchema()
            ],
            required: ["status"]
        )
    }
}
```

Make the API call using the wrapper struct:

```swift
let request = ChatCompletionRequest(
    model: "openai/gpt-4o",
    messages: [
        .init(role: .system, content: "You are an assistant that determines task status. Respond with *only* one of the following strings based on the user query: PENDING, PROCESSING, COMPLETED, FAILED, wrapped in a JSON object with a 'status' key, according to the schema derived from the TaskStatusResponse type."),
        .init(role: .user, content: "Is the analysis task finished?")
    ]
)

do {
    // 4. Call getChatCompletion with the wrapper type
    let response: TaskStatusResponse = try await client.getChatCompletion(
        request: request,
        responseType: TaskStatusResponse.self
    )
    print("Current Task Status: \(response.status)") // Access the enum via the wrapper
} catch {
    print("Error getting structured enum completion: \(error)")
}
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
