//
//  TrackersGenerator.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import PromiseKit

protocol TrackersGenerator {

    // MARK: - Instance Methods

    func generate(configuration: GenerationConfiguration) -> Promise<Void>
}
