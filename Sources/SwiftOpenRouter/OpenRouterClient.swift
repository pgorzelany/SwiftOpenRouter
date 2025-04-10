import Foundation

public final actor OpenRouterClient {
    // MARK: Properties

    private let baseURL = URL(string: "https://openrouter.ai/api/v1")!
    private let urlSession = URLSession(configuration: .default)
    private let apiKey: String
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let streamingClient: OpenRouterStreamingClient

    // MARK: Lifecycle

    public init(apiKey: String) {
        self.apiKey = apiKey
        jsonDecoder = .init()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        jsonEncoder = .init()
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
        streamingClient = .init(apiKey: apiKey)
    }

    // MARK: Methods

    private func performDataRequest(_ request: OpenRouterRequest) async throws -> Data {
        let urlRequest = try createUrlRequest(with: request)
        let (data, response) = try await urlSession.data(for: urlRequest)
        try validateResponse(response, data: data)
        return data
    }

    private func performDecodableRequest<T: Decodable>(_ request: OpenRouterRequest) async throws -> T {
        let data = try await performDataRequest(request)
        return try jsonDecoder.decode(T.self, from: data)
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenRouterError.invalidResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if let errorResponse = try? jsonDecoder.decode(OpenRouterErrorResponse.self, from: data) {
                throw OpenRouterError.errorResponse(errorResponse)
            } else {
                throw OpenRouterError.invalidStatusCode(httpResponse.statusCode)
            }
        }
    }

    private func createUrlRequest(with openRouterRequest: OpenRouterRequest) throws -> URLRequest {
        var request = URLRequest(url: openRouterRequest.url)
        request.httpMethod = openRouterRequest.method.rawValue
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = openRouterRequest.body {
            request.httpBody = try jsonEncoder.encode(body)
        }

        return request
    }

    public func getAvailableModels() async throws -> ListAvailableModelsResponse {
        let url = OpenRouterEndpoint.models.url(baseURL: baseURL)
        let request = OpenRouterRequest(method: .get, url: url, body: nil, headers: [:])
        return try await performDecodableRequest(request)
    }

    public func getCredits() async throws -> GetCreditsResponse {
        let url = OpenRouterEndpoint.credits.url(baseURL: baseURL)
        let request = OpenRouterRequest(method: .get, url: url, body: nil, headers: [:])
        return try await performDecodableRequest(request)
    }

    public func getChatCompletion(request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
        let url = OpenRouterEndpoint.chatCompletions.url(baseURL: baseURL)
        let request = OpenRouterRequest(method: .post, url: url, body: request, headers: [:])
        return try await performDecodableRequest(request)
    }

    /// Sends a chat completion request and decodes the response directly into the specified Decodable & JSONSchemaConvertible type.
    /// Automatically generates the `response_format` based on the schema derived from `T`.
    /// - Parameters:
    ///   - request: The base chat completion request (model, messages, etc.). Any `responseFormat` in this request will be ignored.
    ///   - responseType: The type `T` to decode the response into. Must conform to `Decodable` and `JSONSchemaConvertible`.
    /// - Returns: An instance of type `T` decoded from the response content.
    /// - Throws: `OpenRouterError` if the API call fails, content is missing, or decoding fails.
    public func getChatCompletion<T: Decodable & JSONSchemaConvertible>(
        request: ChatCompletionRequest,
        responseType: T.Type
    ) async throws -> T {
        // 1. Generate schema and response format from the type T
        let schemaDefinition = responseType.jsonSchema()
        // Use the type name as the schema name by default
        let schemaName = String(describing: responseType)
        let schemaWrapper = JSONSchema(name: schemaName, strict: true, definition: schemaDefinition)
        let responseFormat = ResponseFormat(jsonSchema: schemaWrapper)

        // 2. Create a modified request ensuring the correct response format is set
        // Also explicitly disable streaming for this non-streaming method.
        let modifiedRequest = ChatCompletionRequest(
            model: request.model,
            messages: request.messages,
            stream: false, // Ensure not streaming
            maxTokens: request.maxTokens,
            temperature: request.temperature,
            seed: request.seed,
            topP: request.topP,
            topK: request.topK,
            frequencyPenalty: request.frequencyPenalty,
            presencePenalty: request.presencePenalty,
            repetitionPenalty: request.repetitionPenalty,
            logitBias: request.logitBias,
            topLogprobs: request.topLogprobs,
            minP: request.minP,
            topA: request.topA,
            transforms: request.transforms,
            models: request.models,
            route: request.route,
            provider: request.provider,
            reasoning: request.reasoning,
            responseFormat: responseFormat // Set the generated format
        )

        // 3. Call the underlying chat completion method
        let rawResponse = try await getChatCompletion(request: modifiedRequest)

        // 4. Extract content
        guard let content = rawResponse.choices.first?.message.content else {
            // Consider throwing a specific error if content is missing
            throw OpenRouterError.missingContent(response: rawResponse)
        }

        // 5. Decode content into type T
        guard let contentData = content.data(using: .utf8) else {
            throw OpenRouterError.invalidResponseData(message: "Could not convert response content string to Data.")
        }

        do {
            let decodedObject = try jsonDecoder.decode(T.self, from: contentData)
            return decodedObject
        } catch let decodingError as DecodingError {
            // Provide more context for decoding errors
            throw OpenRouterError.decodingFailed(underlyingError: decodingError, data: contentData)
        } catch {
            // Catch other potential errors during decoding
            throw OpenRouterError.decodingFailed(underlyingError: error, data: contentData)
        }
    }

    public func streamChatCompletion(request: ChatCompletionRequest) async throws -> AsyncThrowingStream<ChatCompletionChunk, Error> {
        return try await streamingClient.streamChatCompletion(request: request)
    }

    public func stopStreaming() async {
        await streamingClient.stopStreaming()
    }
}
