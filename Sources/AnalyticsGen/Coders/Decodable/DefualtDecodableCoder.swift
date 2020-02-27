//
//  DefualtDecodableCoder.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation

final class DefaultDecodableCoder: DecodableCoder {

    // MARK: - DecodableCoder

    func encode<T: Encodable>(_ object: T, encoder: JSONEncoder) throws -> [String: Any] {
        let data = try encoder.encode(object)
        let object = try JSONSerialization.jsonObject(with: data)

        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(
                codingPath: [],
                debugDescription: "Deserialized object is not a dictionary"
            )

            throw DecodingError.typeMismatch(type(of: object), context)
        }

        return json
    }

    func encode<T: Encodable>(_ array: [T], encoder: JSONEncoder) throws -> [[String: Any]] {
        let data = try encoder.encode(array)
        let object = try JSONSerialization.jsonObject(with: data)

        guard let json = object as? [[String: Any]] else {
            let context = DecodingError.Context(
                codingPath: [],
                debugDescription: "Deserialized object is not a array"
            )

            throw DecodingError.typeMismatch(type(of: object), context)
        }

        return json
    }

    // MARK: -

    func decode<T: Decodable>(from json: [String: Any], decoder: JSONDecoder) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: json)

        return try decoder.decode(from: data)
    }

    func decode<T: Decodable>(from json: [[String: Any]], decoder: JSONDecoder) throws -> [T] {
        let data = try JSONSerialization.data(withJSONObject: json)

        return try decoder.decode(from: data)
    }
}
