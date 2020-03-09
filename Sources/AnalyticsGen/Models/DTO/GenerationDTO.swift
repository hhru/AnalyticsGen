//
//  GenerationDTO.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 09/03/2020.
//

import Foundation

struct GenerationDTO: Codable {

    // MARK: - Instance Properties

    let trackers: [Tracker]
    let events: [Event]
}
