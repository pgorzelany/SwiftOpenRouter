import Foundation

public enum OpenRouterError: LocalizedError {
    case errorResponse(OpenRouterErrorResponse)
    case invalidResponse
    case invalidStatusCode(Int)
    case missingContent(response: ChatCompletionResponse)
    case invalidResponseData(message: String)
    case decodingFailed(underlyingError: Error, data: Data)

    public var errorDescription: String? {
        switch self {
        case .invalidStatusCode(let code):
            return "Invalid status code: \(code)"
        case .errorResponse(let response):
            return "API Error (\(response.error.code ?? -1)): \(response.error.message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .missingContent:
            return "Missing content in chat completion response."
        case .invalidResponseData(let message):
            return "Invalid response data: \(message)"
        case .decodingFailed(let underlyingError, let data):
            let dataString = String(data: data, encoding: .utf8) ?? "<Non UTF-8 Data>"
            return "Failed to decode response: \(underlyingError.localizedDescription)\nRaw data: \(dataString)"
        }
    }
}
