//
//  Tracker.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation

struct Tracker: Codable {

    // MARK: - Instance Properties

    let id: Int
    let name: String
    let `import`: String
    let events: [Event]
}
