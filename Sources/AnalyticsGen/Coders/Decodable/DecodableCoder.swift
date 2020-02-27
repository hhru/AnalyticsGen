//
//  DecodableCoder.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation

protocol DecodableCoder {

    // MARK: - Instance Methods

    func encode<T: Encodable>(_ object: T, encoder: JSONEncoder) throws -> [String: Any]
    func encode<T: Encodable>(_ array: [T], encoder: JSONEncoder) throws -> [[String: Any]]

    func decode<T: Decodable>(from json: [String: Any], decoder: JSONDecoder) throws -> T
    func decode<T: Decodable>(from json: [[String: Any]], decoder: JSONDecoder) throws -> [T]
}

// MARK: -

extension DecodableCoder {

    // MARK: - Instance Methods

    func encode<T: Encodable>(_ object: T, encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        return try self.encode(object, encoder: encoder)
    }

    func encode<T: Encodable>(_ array: [T], encoder: JSONEncoder = JSONEncoder()) throws -> [[String: Any]] {
        return try self.encode(array, encoder: encoder)
    }

    // MARK: -

    func decode<T: Decodable>(from json: [String: Any], decoder: JSONDecoder = JSONDecoder()) throws -> T {
        return try self.decode(from: json, decoder: decoder)
    }

    func decode<T: Decodable>(from json: [[String: Any]], decoder: JSONDecoder = JSONDecoder()) throws -> [T] {
        return try self.decode(from: json, decoder: decoder)
    }
}
