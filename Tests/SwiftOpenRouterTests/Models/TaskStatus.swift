import Foundation
@testable import SwiftOpenRouter

enum TaskStatus: String, Decodable, Equatable, CaseIterable {
    case pending = "PENDING"
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case failed = "FAILED"
}

// Add the missing implementation for JSONSchemaConvertible
extension TaskStatus: JSONSchemaConvertible {
    static var schemaDefinition: JSONSchemaDefinition {
        .enum(
            description: "Possible states of a task.",
            values: TaskStatus.allCases.map { .string($0.rawValue) }
        )
    }
} 