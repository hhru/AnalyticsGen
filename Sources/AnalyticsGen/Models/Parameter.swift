//
//  Parameter.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation

struct Parameter: Codable {

    // MARK: - Instance Properties

    let id: Int
    let name: String
    let description: String
    let isOptional: Bool
    let type: String
}
