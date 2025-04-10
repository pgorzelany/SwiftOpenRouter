import Foundation

public enum OpenRouterEndpoint {
    case chatCompletions
    case models
    case credits

    var path: String {
        switch self {
        case .chatCompletions:
            return "/chat/completions"
        case .models:
            return "/models"
        case .credits:
            return "/credits"
        }
    }

    func url(baseURL: URL) -> URL {
        baseURL.appendingPathComponent(path)
    }
}
