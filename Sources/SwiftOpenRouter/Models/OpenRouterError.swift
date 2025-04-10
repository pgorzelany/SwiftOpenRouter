import Foundation

public enum OpenRouterError: LocalizedError {
    case errorResponse(OpenRouterErrorResponse)
    case invalidResponse
    case invalidStatusCode(Int)

    public var errorDescription: String? {
        switch self {
        case .invalidStatusCode(let code):
            return "Invalid status code: \(code)"
        case .errorResponse(let response):
            return "API Error (\(response.error.code)): \(response.error.message)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
