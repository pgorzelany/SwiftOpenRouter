import Foundation
@testable import SwiftOpenRouter

enum TaskStatus: String, Decodable, Equatable, CaseIterable, JSONSchemaConvertible {
    case pending = "PENDING"
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case failed = "FAILED"
} 