//
//  AnalyticsTrackersProvider.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import PromiseKit

protocol AnalyticsTrackersProvider {

    // MARK: - Instance Methods

    func fetchAnalyticsTrackers() -> Promise<[Tracker]>
}
