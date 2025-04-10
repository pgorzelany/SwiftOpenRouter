//
//  JSONSchemaConvertible.swift
//  SwiftOpenRouter
//
//  Created by AI Assistant on [Current Date].
//

import Foundation

/// A type that can be represented as a JSONSchema.
public protocol JSONSchemaConvertible {
    /// Returns the JSONSchema definition for this type.
    static func jsonSchema() -> JSONSchemaDefinition
}

// MARK: - Standard Type Conformances

extension String: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .string()
    }
}

extension Int: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .integer()
    }
}

extension Double: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .number()
    }
}

// Float can also be represented as number
extension Float: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .number()
    }
}

extension Bool: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .boolean()
    }
}

// Date can be represented as a string with format
extension Date: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .string(format: "date-time")
    }
}

// URL can be represented as a string with format
extension URL: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .string(format: "uri")
    }
}

// UUID can be represented as a string with format
extension UUID: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .string(format: "uuid")
    }
}

// MARK: - Optional Conformance

extension Optional: JSONSchemaConvertible where Wrapped: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        // JSON Schema optionality is typically handled by the 'required' array in objects.
        // The schema for Optional<T> is the same as the schema for T.
        return Wrapped.jsonSchema()
    }
}

// MARK: - Collection Conformances

extension Array: JSONSchemaConvertible where Element: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        return .array(items: Element.jsonSchema())
    }
}

// Dictionary: JSON Schema typically models dictionaries as objects
// with 'additionalProperties' specifying the value type.
extension Dictionary: JSONSchemaConvertible where Key == String, Value: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        // Representing as an object where keys are strings and values match Value's schema.
        // Note: Setting additionalProperties to Value.jsonSchema() is technically more correct
        // but requires additionalProperties to accept a JSONSchema, not just Bool.
        // For simplicity now, we represent it as a generic object or an object allowing any properties.
        // A common pattern is object with additionalProperties: true or additionalProperties: { <value_schema> }
        // Sticking to simpler representation for now.
        return .object(additionalProperties: true) // Simplistic representation
        // TODO: Enhance to support additionalProperties: <Schema> when needed.
    }
}

// MARK: - Enum Conformance

extension JSONSchemaConvertible where Self: RawRepresentable & CaseIterable, Self.RawValue: JSONSchemaConvertible {
    public static func jsonSchema() -> JSONSchemaDefinition {
        // Get the schema type from the RawValue
        let baseSchema = RawValue.jsonSchema()

        // Extract raw values and convert to JSONSchemaValue
        let enumValues: [JSONSchemaValue]? = Self.allCases.compactMap { enumCase in
            switch enumCase.rawValue {
            case let str as String: return .string(str)
            case let int as Int: return .integer(int)
            case let dbl as Double: return .number(dbl)
            case let bool as Bool: return .boolean(bool)
            // Add other RawValue types if needed
            default: return nil
            }
        }

        // Return the base schema type with the enum values
        switch baseSchema.type {
        case .string:
            return .string(description: baseSchema.description, enumValues: enumValues)
        case .integer:
            return .integer(description: baseSchema.description, enumValues: enumValues)
        case .number:
            return .number(description: baseSchema.description, enumValues: enumValues)
        // Boolean enums are less common, handle if necessary
        // Object/Array raw values for enums are unlikely/unsupported here
        default:
            // Fallback or assertion if RawValue schema type is unexpected
            assertionFailure("Unsupported RawValue type for Enum schema generation: \(baseSchema.type)")
            return baseSchema // Return base schema without enum values as fallback
        }
    }
}
