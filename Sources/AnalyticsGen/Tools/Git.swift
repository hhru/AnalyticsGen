import Foundation
import AnalyticsGenTools

enum Git {

    /// Проверяет, что текущая директория находится внутри git репозитория.
    /// - Throws: Ошибка, если директория не является git репозиторием.
    static func ensureGitRepository() throws {
        do {
            try shell("git rev-parse --git-dir")
        } catch {
            throw MessageError("Not a git repository, failed git check")
        }
    }

    /// Возвращает имя текущей ветки.
    /// - Returns: Имя ветки; в состоянии detached HEAD — строка "HEAD".
    /// - Throws: Ошибка при выполнении git команд.
    static func currentBranch() throws -> String {
        try shell("git rev-parse --abbrev-ref HEAD")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Возвращает пути из переданного списка, в которых есть незакоммиченные изменения
    /// (включая untracked файлы и удаления).
    /// - Parameter paths: Список путей для проверки.
    /// - Returns: Подмножество `paths`, в которых есть изменения.
    static func changedPaths(in paths: [String]) throws -> [String] {
        try paths.filter { path in
            let status = try shell("git status --porcelain -- \"\(path)\"")
            return !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    /// Проверяет, есть ли на текущей ветке (в диапазоне origin/<baseBranch>..HEAD)
    /// коммиты, затрагивающие указанные пути.
    /// - Parameters:
    ///   - paths: Пути для проверки, относительно корня репозитория.
    ///   - baseBranch: Базовая ветка; origin/<baseBranch> должен быть актуален
    ///     (fetch выполняется ранее в прогоне, см. `checkNoForeignAnalyticsTags`).
    /// - Returns: `true`, если хоть один коммит ветки затрагивает пути; `false` иначе.
    /// - Note: Пустой список путей трактуется как «коммитов нет».
    static func hasBranchCommits(in paths: [String], baseBranch: String) throws -> Bool {
        guard !paths.isEmpty else {
            return false
        }

        let pathspecs = paths.map { "\"\($0)\"" }.joined(separator: " ")
        let commits = try shell("git log --pretty=%H \"origin/\(baseBranch)..HEAD\" -- \(pathspecs)")

        return !commits.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Получает следующий индекс для инкрементального тега.
    /// - Parameter prefix: Префикс тега (например, "analytics/branch").
    /// - Returns: Следующий индекс для тега.
    /// - Throws: Ошибка при выполнении git команд.
    static func getNextTagIndex(for prefix: String) throws -> Int {
        try shell("git fetch --tags --force")
        let allTags = try shell("git tag -l")

        let tagList = allTags.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let indices = tagList.compactMap { tag -> Int? in
            guard tag.hasPrefix(prefix + "-") else {
                return nil
            }

            let indexString = tag.dropFirst((prefix + "-").count)
            return Int(indexString)
        }

        return (indices.max() ?? 0) + 1
    }

    /// Создает коммит только из переданных путей и добавляет тег.
    /// Изменения вне `paths` (в том числе staged) в коммит не попадают.
    /// - Parameters:
    ///   - message: Сообщение коммита.
    ///   - tag: Название тега.
    ///   - paths: Пути, которые попадут в коммит.
    /// - Throws: Ошибка при выполнении git команд.
    static func commitAndTag(message: String, tag: String, paths: [String]) throws {
        guard !paths.isEmpty else {
            throw MessageError("No analytics paths to stage")
        }

        let pathspecs = paths.map { "\"\($0)\"" }.joined(separator: " ")

        try shell("git add -- \(pathspecs)")
        Log.debug("Staged analytics paths: \(paths.joined(separator: ", "))")

        try shell("git commit -m \"\(message)\" -- \(pathspecs)")
        Log.info("Created commit: \(message)")

        try shell("git tag \"\(tag)\"")
        Log.info("Created tag: \(tag)")
    }

    /// Извлекает имя analyst-ветки из тега аналитики.
    /// Формат тега: `analytics/<branch>-<index>`; хвостовой `-<index>` отбрасывается, если он числовой.
    /// - Parameter tag: Название тега.
    /// - Returns: Имя analyst-ветки или `nil`, если тег не аналитический.
    static func analystBranch(fromAnalyticsTag tag: String) -> String? {
        let prefix = "analytics/"

        guard tag.hasPrefix(prefix) else {
            return nil
        }

        let name = tag.dropFirst(prefix.count)

        if let dashIndex = name.lastIndex(of: "-"), dashIndex != name.startIndex {
            let tail = name[name.index(after: dashIndex)...]

            if !tail.isEmpty, tail.allSatisfy({ $0.isASCII && $0.isNumber }) {
                return String(name[..<dashIndex])
            }
        }

        return name.isEmpty ? nil : String(name)
    }

    /// Проверяет, что на текущей ветке (в диапазоне origin/<baseBranch>..HEAD)
    /// нет тегов аналитики от другой analyst-ветки.
    /// - Parameters:
    ///   - branch: Имя текущей analyst-ветки (значение --branch).
    ///   - baseBranch: Базовая ветка consumer-репозитория.
    /// - Throws: MessageError, если найден тег аналитики от другой ветки.
    static func checkNoForeignAnalyticsTags(branch: String, baseBranch: String) throws {
        try shell("git fetch origin \(baseBranch)")
        try shell("git fetch --tags --force")

        let rangeTags = try shell("git tag --merged HEAD --no-merged origin/\(baseBranch)")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let foreignBranches = Set(
            rangeTags
                .compactMap { analystBranch(fromAnalyticsTag: $0) }
                .filter { $0 != branch }
        )

        let sortedForeignBranches = foreignBranches.sorted()

        guard let firstForeignBranch = sortedForeignBranches.first else {
            Log.debug("No foreign analytics tags on branch ✓")
            return
        }

        throw MessageError(
            """
            ❌ Branch already contains analytics generated from another branch: \(sortedForeignBranches.joined(separator: ", ")).
            A pull request must contain analytics from a single branch.
            To combine them, merge your analytics branch into '\(firstForeignBranch)' and rerun with --branch \(firstForeignBranch),
            or generate from a clean feature branch off '\(baseBranch)'.
            """
        )
    }

    /// Отправляет только тег в удаленный репозиторий (без push коммита).
    /// - Parameter tag: Название тега для отправки.
    /// - Throws: Ошибка при выполнении git команд.
    static func pushTag(_ tag: String) throws {
        try shell("git push origin \"\(tag)\"")
        Log.info("Pushed tag '\(tag)' to remote repository")
    }
}
