//
//  Event.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation

struct Event: Codable {

    // MARK: - Instance Properties

    let id: Int
    let name: String
    let description: String
    let parameters: [Parameter]
}
