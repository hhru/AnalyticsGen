//
//  AnalyticsGenAPIVersion.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation

enum AnalyticsGenAPIVersion {

    // MARK: - Enumeration Cases

    case v1

    // MARK: - Instance Properties

    var urlPath: String {
        switch self {
        case .v1:
            return "v1"
        }
    }
}
