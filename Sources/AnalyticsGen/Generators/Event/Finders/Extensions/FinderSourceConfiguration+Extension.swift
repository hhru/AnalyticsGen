import Foundation
import AnalyticsGenTools

extension FinderSourceConfiguration {

    func satisfiedValue() throws -> String? {
        switch type {
        case .environment(let variables):
            return try variables
                .lazy
                .compactMap { ProcessInfo.processInfo.environment[$0] }
                .compactMap { try condition.extract(from: $0) }
                .first

        case .file(let paths):
            return try paths
                .lazy
                .filter { FileManager.default.fileExists(atPath: $0) }
                .map { URL(fileURLWithPath: $0) }
                .map { try String(contentsOf: $0, encoding: .utf8) }
                .compactMap { try condition.extract(from: $0) }
                .first

        case .git(let type):
            switch type {
            case .currentBranchName:
                let currentBranch = try shell("git rev-parse --abbrev-ref HEAD")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                return try condition.extract(from: currentBranch)
            }
        }
    }

    func isSatisfyCondition() throws -> Bool {
        try satisfiedValue() != nil
    }
}

private extension FinderConditionConfiguration {

    func extract(from value: String) throws -> String? {
        switch self {
        case .regex(let string):
            let valueRange = NSRange(value.startIndex ..< value.endIndex, in: value)
            let regex = try NSRegularExpression(pattern: string)
            let matches = regex.matches(in: value, range: valueRange)

            guard let match = matches.first else {
                return nil
            }

            if match.numberOfRanges == 1 {
                return value
            } else if let firstGroupRange = Range(match.range(at: 1), in: value) {
                return String(value[firstGroupRange])
            } else {
                return nil
            }

        case .equal(let string):
            return value == string ? value : nil

        case .notEqual(let string):
            return value != string ? value : nil
        }
    }
}
