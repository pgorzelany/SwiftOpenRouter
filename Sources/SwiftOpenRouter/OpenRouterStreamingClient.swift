//
//  OpenRouterStreamingClient.swift
//  SwiftOpenRouter
//
//  Created by Piotr Gorzelany on 22/03/2025.
//

import Foundation

public final actor OpenRouterStreamingClient {
    // MARK: Properties
    
    private let baseURL = URL(string: "https://openrouter.ai/api/v1")!
    private let urlSession = URLSession(configuration: .default)
    private let apiKey: String
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private var currentTask: Task<Void, Error>?

    // MARK: Lifecycle
    
    public init(apiKey: String) {
        self.apiKey = apiKey
        jsonDecoder = .init()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        jsonEncoder = .init()
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
    }
    
    // MARK: Methods

    public func streamChatCompletion(request: ChatCompletionRequest) async throws -> AsyncThrowingStream<ChatCompletionChunk, Error> {
        stopStreaming()
        
        let urlRequest = try createUrlRequest(
            for: .chatCompletions,
            with: request,
            isStreaming: true
        )

        return AsyncThrowingStream { continuation in
            currentTask = Task {
                do {
                    let (asyncBytes, response) = try await urlSession.bytes(for: urlRequest)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: OpenRouterError.invalidResponse)
                        return
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        if let errorResponse = try await processErrorResponse(asyncBytes: asyncBytes) {
                            continuation.finish(throwing: OpenRouterError.errorResponse(errorResponse))
                        } else {
                            continuation.finish(throwing: OpenRouterError.invalidStatusCode(httpResponse.statusCode))
                        }

                        return
                    }

                    try await processSSEResponse(asyncBytes: asyncBytes) { chunk in
                        guard !Task.isCancelled else {
                            continuation.finish()
                            return
                        }
                        continuation.yield(chunk)
                    }

                    continuation.finish()
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func stopStreaming() {
        currentTask?.cancel()
    }

    private func createUrlRequest(for endpoint: OpenRouterEndpoint, with body: Encodable?, isStreaming: Bool = false) throws -> URLRequest {
        let url = endpoint.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if isStreaming {
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        }

        if let body = body {
            request.httpBody = try jsonEncoder.encode(body)
        }

        return request
    }

    private func processErrorResponse(asyncBytes: URLSession.AsyncBytes) async throws -> OpenRouterErrorResponse? {
        var errorData = Data()
        for try await byte in asyncBytes.prefix(1024 * 1024) {
            errorData.append(contentsOf: [byte])
        }

        if let errorResponse = try? jsonDecoder.decode(OpenRouterErrorResponse.self, from: errorData) {
            return errorResponse
        }

        return nil
    }

    private func processSSEResponse(
        asyncBytes: URLSession.AsyncBytes,
        onChunk: @escaping (ChatCompletionChunk) -> Void
    ) async throws {
        for try await line in asyncBytes.lines {
            guard let jsonString = line.stripPrefix("data: ") else { continue }

            if let jsonData = jsonString.data(using: .utf8),
               let chunk = try? jsonDecoder.decode(ChatCompletionChunk.self, from: jsonData) {
                onChunk(chunk)
            }
        }
    }
}

// Helper extension to strip prefix if it exists
private extension StringProtocol {
    func stripPrefix(_ prefix: String) -> String? {
        guard self.hasPrefix(prefix) else { return nil }
        return String(self.dropFirst(prefix.count))
    }
}
