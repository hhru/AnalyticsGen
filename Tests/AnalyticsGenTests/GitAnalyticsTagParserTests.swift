import Testing
@testable import AnalyticsGen

@Suite
struct GitAnalyticsTagParserTests {

    @Test
    func parsesStandardTag() {
        #expect(Git.analystBranch(fromAnalyticsTag: "analytics/MOB-62703-3") == "MOB-62703")
    }

    @Test
    func returnsNilForNonAnalyticsTag() {
        #expect(Git.analystBranch(fromAnalyticsTag: "release/1.2.3") == nil)
    }

    @Test
    func stripsOnlyNumericTail() {
        #expect(Git.analystBranch(fromAnalyticsTag: "analytics/MOB-6-fix") == "MOB-6-fix")
        #expect(Git.analystBranch(fromAnalyticsTag: "analytics/fix") == "fix")
    }

    @Test
    func doesNotStripNonASCIINumericTail() {
        #expect(Git.analystBranch(fromAnalyticsTag: "analytics/X-٣") == "X-٣")
        #expect(Git.analystBranch(fromAnalyticsTag: "analytics/X-Ⅻ") == "X-Ⅻ")
    }

    @Test
    func distinguishesPrefixCollisions() {
        #expect(Git.analystBranch(fromAnalyticsTag: "analytics/MOB-62-1") == "MOB-62")
        #expect(Git.analystBranch(fromAnalyticsTag: "analytics/MOB-6-2-1") == "MOB-6-2")
        #expect(Git.analystBranch(fromAnalyticsTag: "analytics/MOB-6-1") == "MOB-6")
    }
}
