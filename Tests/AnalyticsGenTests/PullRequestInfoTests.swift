import Testing
import Foundation
@testable import AnalyticsGen

struct PullRequestInfoTests {

    @Test
    func decodesForgejoPayload() throws {
        let json = Data("""
        {
            "number": 42,
            "title": "AN-123 Новое событие",
            "state": "open",
            "merged": false,
            "mergeable": true,
            "html_url": "https://forgejo.pyn.ru/hhru/hh-mobile-analytics/pulls/42",
            "head": { "ref": "AN-123-ios", "label": "AN-123-ios", "sha": "0a1b2c3d" },
            "base": { "ref": "develop-ios", "label": "develop-ios" }
        }
        """.utf8)

        let pr = try JSONDecoder().decode(PullRequestInfo.self, from: json)

        #expect(pr.number == 42)
        #expect(pr.title == "AN-123 Новое событие")
        #expect(pr.state == .open)
        #expect(pr.merged == false)
        #expect(pr.mergeable == true)
        #expect(pr.head.ref == "AN-123-ios")
        #expect(pr.head.label == "AN-123-ios")
        #expect(pr.head.sha == "0a1b2c3d")
        #expect(pr.base.ref == "develop-ios")
        #expect(pr.base.sha == nil)
        #expect(pr.htmlURL == URL(string: "https://forgejo.pyn.ru/hhru/hh-mobile-analytics/pulls/42"))
    }

    @Test
    func decodesMissingMergeableAndShaAsNil() throws {
        let json = Data("""
        {
            "number": 42,
            "title": "x",
            "state": "open",
            "html_url": "https://forgejo.pyn.ru/x/y/pulls/42",
            "head": { "ref": "b", "label": "b" },
            "base": { "ref": "master", "label": "master" }
        }
        """.utf8)

        let pr = try JSONDecoder().decode(PullRequestInfo.self, from: json)

        #expect(pr.mergeable == nil)
        #expect(pr.head.sha == nil)
    }

    @Test
    func decodesUnknownStateWithoutThrowing() throws {
        let json = Data("""
        {
            "number": 7,
            "title": "x",
            "state": "draft",
            "html_url": "https://forgejo.pyn.ru/x/y/pulls/7",
            "head": { "ref": "b", "label": "b" },
            "base": { "ref": "master", "label": "master" }
        }
        """.utf8)

        let pr = try JSONDecoder().decode(PullRequestInfo.self, from: json)

        #expect(pr.state == .unknown)
    }

    private func pr(ref: String, label: String) -> PullRequestInfo {
        PullRequestInfo(
            number: 1,
            title: "x",
            state: .open,
            merged: false,
            mergeable: nil,
            head: .init(ref: ref, label: label, sha: nil),
            base: .init(ref: "master", label: "master", sha: nil),
            htmlURL: URL(string: "https://forgejo.pyn.ru/x/y/pulls/1")!
        )
    }

    @Test
    func headMatchesByLabelForOpenPR() {
        #expect(pr(ref: "AN-123", label: "AN-123").headMatches(branch: "AN-123"))
    }

    @Test
    func headMatchesByLabelForMergedPRWithDeletedBranch() {
        // После merge ref становится refs/pull/N/head, но label сохраняет имя ветки.
        let merged = pr(ref: "refs/pull/2863/head", label: "PORTFOLIO-54190")
        #expect(merged.headMatches(branch: "PORTFOLIO-54190"))
    }

    @Test
    func headMatchesForkLabel() {
        #expect(pr(ref: "refs/pull/9/head", label: "fork-owner:AN-123").headMatches(branch: "AN-123"))
    }

    @Test
    func headDoesNotMatchDifferentBranch() {
        #expect(!pr(ref: "AN-999", label: "AN-999").headMatches(branch: "AN-123"))
    }
}
