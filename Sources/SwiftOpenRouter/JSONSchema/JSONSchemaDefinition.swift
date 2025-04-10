/// Represents the top-level wrapper for JSON schema structure sent to the API.
final public class JSONSchema: Encodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case name
        case strict
        case schema
    }

    public let name: String
    public let strict: Bool
    public let definition: JSONSchemaDefinition // Renamed from SchemaDefinition

    public init(name: String, strict: Bool, definition: JSONSchemaDefinition) {
        self.name = name
        self.strict = strict
        self.definition = definition
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(strict, forKey: .strict)
        try container.encode(definition, forKey: .schema)
    }
}

/// Represents the possible types in a JSON Schema.
public enum SchemaType: String, Encodable, Sendable {
    case string
    case number
    case integer
    case boolean
    case object
    case array
}

/// Represents JSON primitive values usable in enums.
public enum JSONSchemaValue: Encodable, Sendable {
    case string(String)
    case integer(Int)
    case number(Double)
    case boolean(Bool)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .integer(let i): try container.encode(i)
        case .number(let n): try container.encode(n)
        case .boolean(let b): try container.encode(b)
        }
    }
}

/// Defines the structure and constraints of a JSON schema.
/// Use static factory methods like `.string()`, `.object()`, etc. to create instances.
final public class JSONSchemaDefinition: Encodable, Sendable { // Renamed from SchemaDefinition

    // Common properties
    public let type: SchemaType
    public let description: String?
    public let enumValues: [JSONSchemaValue]?

    // Type-specific properties (omitting for brevity, same as before)
    public let minLength: Int?
    public let maxLength: Int?
    public let pattern: String?
    public let format: String?
    public let minimum: Double?
    public let maximum: Double?
    public let exclusiveMinimum: Double?
    public let exclusiveMaximum: Double?
    public let multipleOf: Double?
    public let properties: [String: JSONSchemaDefinition]? // Type updated
    public let required: [String]?
    public let additionalProperties: Bool?
    public let minProperties: Int?
    public let maxProperties: Int?
    public let items: JSONSchemaDefinition? // Type updated
    public let minItems: Int?
    public let maxItems: Int?
    public let uniqueItems: Bool?

    // Private init used by factory methods
    private init(
        type: SchemaType,
        description: String? = nil,
        enumValues: [JSONSchemaValue]? = nil,
        // String
        minLength: Int? = nil,
        maxLength: Int? = nil,
        pattern: String? = nil,
        format: String? = nil,
        // Number/Integer
        minimum: Double? = nil,
        maximum: Double? = nil,
        exclusiveMinimum: Double? = nil,
        exclusiveMaximum: Double? = nil,
        multipleOf: Double? = nil,
        // Object
        properties: [String : JSONSchemaDefinition]? = nil, // Type updated
        required: [String]? = nil,
        additionalProperties: Bool? = nil,
        minProperties: Int? = nil,
        maxProperties: Int? = nil,
        // Array
        items: JSONSchemaDefinition? = nil, // Type updated
        minItems: Int? = nil,
        maxItems: Int? = nil,
        uniqueItems: Bool? = nil
    ) {
        self.type = type
        self.description = description
        self.enumValues = enumValues
        self.minLength = minLength
        self.maxLength = maxLength
        self.pattern = pattern
        self.format = format
        self.minimum = minimum
        self.maximum = maximum
        self.exclusiveMinimum = exclusiveMinimum
        self.exclusiveMaximum = exclusiveMaximum
        self.multipleOf = multipleOf
        self.properties = properties
        self.required = required
        self.additionalProperties = additionalProperties
        self.minProperties = minProperties
        self.maxProperties = maxProperties
        self.items = items
        self.minItems = minItems
        self.maxItems = maxItems
        self.uniqueItems = uniqueItems
    }

    // --- Swift-friendly Factory Methods (Now on JSONSchema) ---

    public static func string(
        description: String? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        pattern: String? = nil,
        format: String? = nil,
        enumValues: [JSONSchemaValue]? = nil // Added enumValues
    ) -> JSONSchemaDefinition {
        return JSONSchemaDefinition(
            type: .string,
            description: description,
            enumValues: enumValues,
            minLength: minLength,
            maxLength: maxLength,
            pattern: pattern,
            format: format
        )
    }

    public static func number(
        description: String? = nil,
        minimum: Double? = nil,
        maximum: Double? = nil,
        exclusiveMinimum: Double? = nil,
        exclusiveMaximum: Double? = nil,
        multipleOf: Double? = nil,
        enumValues: [JSONSchemaValue]? = nil // Added enumValues
    ) -> JSONSchemaDefinition {
        return JSONSchemaDefinition(
            type: .number,
            description: description,
            enumValues: enumValues,
            minimum: minimum,
            maximum: maximum,
            exclusiveMinimum: exclusiveMinimum,
            exclusiveMaximum: exclusiveMaximum,
            multipleOf: multipleOf
        )
    }

    public static func integer(
        description: String? = nil,
        minimum: Double? = nil,
        maximum: Double? = nil,
        exclusiveMinimum: Double? = nil,
        exclusiveMaximum: Double? = nil,
        multipleOf: Double? = nil,
        enumValues: [JSONSchemaValue]? = nil // Added enumValues
    ) -> JSONSchemaDefinition {
        return JSONSchemaDefinition(
            type: .integer,
            description: description,
            enumValues: enumValues,
            minimum: minimum,
            maximum: maximum,
            exclusiveMinimum: exclusiveMinimum,
            exclusiveMaximum: exclusiveMaximum,
            multipleOf: multipleOf
        )
    }

    /// Convenience factory for creating a string schema with enum values.
    public static func `enum`(
        description: String? = nil,
        values: [JSONSchemaValue]
    ) -> JSONSchemaDefinition {
        // Determine type based on first value? Or default to string?
        // Defaulting to string for simplicity, matching target library example.
        // Enhance later if necessary to support numeric enums via this func.
        return JSONSchemaDefinition(
            type: .string, // Assuming string enum based on target library
            description: description,
            enumValues: values
        )
    }

    public static func boolean(description: String? = nil) -> JSONSchemaDefinition {
        return JSONSchemaDefinition(type: .boolean, description: description)
    }

    public static func object(
        description: String? = nil,
        properties: [String: JSONSchemaDefinition]? = nil, // Type updated
        required: [String]? = nil,
        additionalProperties: Bool? = false, // Changed default from nil to false
        minProperties: Int? = nil,
        maxProperties: Int? = nil
    ) -> JSONSchemaDefinition {
        return JSONSchemaDefinition(
            type: .object,
            description: description,
            properties: properties,
            required: required,
            additionalProperties: additionalProperties,
            minProperties: minProperties,
            maxProperties: maxProperties
        )
    }

    public static func array(
        description: String? = nil,
        items: JSONSchemaDefinition? = nil, // Type updated
        minItems: Int? = nil,
        maxItems: Int? = nil,
        uniqueItems: Bool? = nil
    ) -> JSONSchemaDefinition {
        return JSONSchemaDefinition(
            type: .array,
            description: description,
            items: items,
            minItems: minItems,
            maxItems: maxItems,
            uniqueItems: uniqueItems
        )
    }

    // Custom Encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(enumValues, forKey: .enum) // Encode enumValues

        // Encode type-specific fields only if they are relevant and non-nil
        switch type {
        case .string:
            try container.encodeIfPresent(minLength, forKey: .minLength)
            try container.encodeIfPresent(maxLength, forKey: .maxLength)
            try container.encodeIfPresent(pattern, forKey: .pattern)
            try container.encodeIfPresent(format, forKey: .format)
           // try container.encodeIfPresent(enumValues, forKey: .enum) // Already handled above
        case .number, .integer:
            try container.encodeIfPresent(minimum, forKey: .minimum)
            try container.encodeIfPresent(maximum, forKey: .maximum)
            try container.encodeIfPresent(exclusiveMinimum, forKey: .exclusiveMinimum)
            try container.encodeIfPresent(exclusiveMaximum, forKey: .exclusiveMaximum)
            try container.encodeIfPresent(multipleOf, forKey: .multipleOf)
           // try container.encodeIfPresent(enumValues, forKey: .enum) // Already handled above
        case .object:
            try container.encodeIfPresent(properties, forKey: .properties)
            try container.encodeIfPresent(required, forKey: .required)
            try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)
            try container.encodeIfPresent(minProperties, forKey: .minProperties)
            try container.encodeIfPresent(maxProperties, forKey: .maxProperties)
        case .array:
            try container.encodeIfPresent(items, forKey: .items)
            try container.encodeIfPresent(minItems, forKey: .minItems)
            try container.encodeIfPresent(maxItems, forKey: .maxItems)
            try container.encodeIfPresent(uniqueItems, forKey: .uniqueItems)
        case .boolean:
            break // No specific fields for boolean currently
             // try container.encodeIfPresent(enumValues, forKey: .enum) // Already handled above
        }
    }

    // Define CodingKeys for encoding
    enum CodingKeys: String, CodingKey {
        case type, description
        case `enum` = "enum"
        // String
        case minLength, maxLength, pattern, format
        // Number/Integer
        case minimum, maximum, exclusiveMinimum, exclusiveMaximum, multipleOf
        // Object
        case properties, required, additionalProperties, minProperties, maxProperties
        // Array
        case items, minItems, maxItems, uniqueItems
    }
} 
