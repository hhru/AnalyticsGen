//
//  TrackerCoder.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation

protocol TrackerCoder {

    // MARK: - Instance Methods

    func encode(trackers: [Tracker]) -> [String: Any]
}
