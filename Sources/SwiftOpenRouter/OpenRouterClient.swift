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

    public func streamChatCompletion(request: ChatCompletionRequest) async throws -> AsyncThrowingStream<ChatCompletionChunk, Error> {
        return try await streamingClient.streamChatCompletion(request: request)
    }

    public func stopStreaming() async {
        await streamingClient.stopStreaming()
    }
}
