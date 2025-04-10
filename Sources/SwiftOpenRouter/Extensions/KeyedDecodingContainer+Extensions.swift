import Foundation

extension KeyedDecodingContainer {
    func decode(_ type: Decimal.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Decimal {
        let stringValue = try decode(String.self, forKey: key)
        guard let decimalValue = Decimal(string: stringValue) else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "Invalid decimal format")
            throw DecodingError.typeMismatch(type, context)
        }
        return decimalValue
    }

    func decodeIfPresent(_ type: Decimal.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Decimal? {
        guard let stringValue = try decodeIfPresent(String.self, forKey: key), !stringValue.isEmpty else {
            return nil
        }
        guard let decimalValue = Decimal(string: stringValue) else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "Invalid decimal format")
            throw DecodingError.dataCorrupted(context)
        }
        return decimalValue
    }
}
