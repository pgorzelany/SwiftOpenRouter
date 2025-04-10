import XCTest
@testable import SwiftOpenRouter

final class JSONSchemaTests: XCTestCase {

    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys] // For consistent comparison
        return encoder
    }()

    func testEncodeSimpleString() throws {
        let schema = JSONSchemaDefinition.string(description: "A simple string")
        let expectedJSON = """
        {
          "description" : "A simple string",
          "type" : "string"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeStringWithConstraints() throws {
        let schema = JSONSchemaDefinition.string(
            description: "Constrained string",
            minLength: 3,
            maxLength: 10,
            pattern: "^[a-z]+$"
        )
        let expectedJSON = """
        {
          "description" : "Constrained string",
          "maxLength" : 10,
          "minLength" : 3,
          "pattern" : "^[a-z]+$",
          "type" : "string"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeNumberWithConstraints() throws {
        let schema = JSONSchemaDefinition.number(
            description: "A price",
            minimum: 0.01,
            maximum: 100.0,
            exclusiveMaximum: 99.99
        )
        let expectedJSON = """
        {
          "description" : "A price",
          "exclusiveMaximum" : 99.99,
          "maximum" : 100,
          "minimum" : 0.01,
          "type" : "number"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeInteger() throws {
        let schema = JSONSchemaDefinition.integer(description: "An age", minimum: 0)
        let expectedJSON = """
        {
          "description" : "An age",
          "minimum" : 0,
          "type" : "integer"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeBoolean() throws {
        let schema = JSONSchemaDefinition.boolean(description: "Is active?")
        let expectedJSON = """
        {
          "description" : "Is active?",
          "type" : "boolean"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeSimpleObject() throws {
        let schema = JSONSchemaDefinition.object(
            description: "A basic object",
            properties: [
                "id": .integer(),
                "name": .string()
            ],
            required: ["id", "name"]
        )
        let expectedJSON = """
        {
          "additionalProperties" : false,
          "description" : "A basic object",
          "properties" : {
            "id" : {
              "type" : "integer"
            },
            "name" : {
              "type" : "string"
            }
          },
          "required" : [
            "id",
            "name"
          ],
          "type" : "object"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeComplexObject() throws {
        let schema = JSONSchemaDefinition.object(
            description: "A complex object",
            properties: [
                "userId": .integer(description: "User ID", minimum: 1),
                "username": .string(description: "Username", minLength: 3),
                "isActive": .boolean(description: "Activation status"),
                "settings": .object(
                    description: "User settings",
                    properties: [
                        "theme": .string(enumValues: [.string("dark"), .string("light")]),
                        "notifications": .boolean()
                    ],
                    required: ["theme"]
                ),
                "tags": .array(
                    description: "User tags",
                    items: .string(minLength: 1),
                    uniqueItems: true
                )
            ],
            required: ["userId", "username", "isActive"],
            additionalProperties: false,
            minProperties: 3
        )

        let expectedJSON = """
        {
          "additionalProperties" : false,
          "description" : "A complex object",
          "minProperties" : 3,
          "properties" : {
            "isActive" : {
              "description" : "Activation status",
              "type" : "boolean"
            },
            "settings" : {
              "additionalProperties" : false,
              "description" : "User settings",
              "properties" : {
                "notifications" : {
                  "type" : "boolean"
                },
                "theme" : {
                  "enum" : [
                    "dark",
                    "light"
                  ],
                  "type" : "string"
                }
              },
              "required" : [
                "theme"
              ],
              "type" : "object"
            },
            "tags" : {
              "description" : "User tags",
              "items" : {
                "minLength" : 1,
                "type" : "string"
              },
              "type" : "array",
              "uniqueItems" : true
            },
            "userId" : {
              "description" : "User ID",
              "minimum" : 1,
              "type" : "integer"
            },
            "username" : {
              "description" : "Username",
              "minLength" : 3,
              "type" : "string"
            }
          },
          "required" : [
            "userId",
            "username",
            "isActive"
          ],
          "type" : "object"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeSimpleArray() throws {
        let schema = JSONSchemaDefinition.array(
            description: "List of numbers",
            items: .number(),
            minItems: 1,
            maxItems: 5
        )
        let expectedJSON = """
        {
          "description" : "List of numbers",
          "items" : {
            "type" : "number"
          },
          "maxItems" : 5,
          "minItems" : 1,
          "type" : "array"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeEnum() throws {
        let schema = JSONSchemaDefinition.enum(
            description: "Task status",
            values: [.string("pending"), .string("running"), .string("completed")]
        )
        let expectedJSON = """
        {
          "description" : "Task status",
          "enum" : [
            "pending",
            "running",
            "completed"
          ],
          "type" : "string"
        }
        """
        try assertSchemaEncoding(schema, equals: expectedJSON)
    }

    func testEncodeSchemaWrapper() throws {
        let definition = JSONSchemaDefinition.object(
            properties: ["value": .number()]
        )
        let wrapper = JSONSchema(name: "my_schema", strict: true, definition: definition)

        let expectedJSON = """
        {
          "name" : "my_schema",
          "schema" : {
            "additionalProperties" : false,
            "properties" : {
              "value" : {
                "type" : "number"
              }
            },
            "type" : "object"
          },
          "strict" : true
        }
        """

        let encodedData = try encoder.encode(wrapper)
        let encodedString = String(data: encodedData, encoding: .utf8) ?? ""
        XCTAssertEqual(encodedString, expectedJSON.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // Helper to encode and compare
    private func assertSchemaEncoding(_ schema: JSONSchemaDefinition, equals expectedJSON: String, file: StaticString = #file, line: UInt = #line) throws {
        let encodedData = try encoder.encode(schema)
        let encodedString = String(data: encodedData, encoding: .utf8) ?? ""
        XCTAssertEqual(encodedString, expectedJSON.trimmingCharacters(in: .whitespacesAndNewlines), file: file, line: line)
    }
} 
