import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnalyticsGenTests.allTests),
    ]
}
#endif
