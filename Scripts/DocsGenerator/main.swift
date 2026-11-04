// Generates every catalog-derived file from `MotionCatalog`, so docs for
// people and for AI tools never drift from the code:
//
//   README.md, README.zh-TW.md             effects grid (between markers)
//   llms.txt, llms-full.txt                https://llmstxt.org
//   Docs/motion-catalog.json               structured data (also read by the MCP server)
//   skills/swiftui-motion/SKILL.md         Agent Skill (Claude Code and others)
//   skills/swiftui-motion/references/effects.md
//   .cursor/rules/swiftui-motion.mdc       Cursor rule
//
// Run through `Scripts/generate-docs.sh`. Usage: DocsGenerator <repo-root> [--check]

import Foundation
import MotionGallery

let repo = "BigTsung/SwiftUI-Motion-Library"
let repoURL = "https://github.com/\(repo)"
let rawURL = "https://raw.githubusercontent.com/\(repo)/main"

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    print("usage: DocsGenerator <repo-root> [--check]")
    exit(2)
}
let root = URL(fileURLWithPath: arguments[1])
let checkOnly = arguments.contains("--check")

let effects = MotionCatalog.all
let groups: [(component: MotionComponent, effects: [MotionEffect])] = MotionComponent.allCases.compactMap { component in
    let members = effects.filter { $0.component == component }
    return members.isEmpty ? nil : (component, members)
}

// MARK: - Helpers

func read(_ path: String, for effect: MotionEffect) -> String {
    let url = root.appendingPathComponent(path)
    guard let text = try? String(contentsOf: url, encoding: .utf8) else {
        fatalError("missing source file for \(effect.id): \(url.path)")
    }
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - Files an effect needs

/// One Swift file of a module, with comments and the trailing `#Preview`
/// removed so only real code is scanned.
struct ScannedFile {
    let path: String
    let code: String
    /// Non-private top-level types, and members of top-level extensions.
    let types: Set<String>
    let members: Set<String>
}

func scanModule(_ directory: String) -> [ScannedFile] {
    let base = root.appendingPathComponent(directory)
    let paths = (FileManager.default.enumerator(atPath: base.path)?.allObjects as? [String] ?? [])
        .filter { $0.hasSuffix(".swift") }
        .sorted()
    let typePattern = try! NSRegularExpression(pattern: #"^(?:@\w+\s+)*(?:public\s+|internal\s+|final\s+)*(?:struct|enum|class|protocol|actor|typealias)\s+(\w+)"#)
    let memberPattern = try! NSRegularExpression(pattern: #"^    (?:@\w+\s+)*(?:public\s+|internal\s+|static\s+|mutating\s+|nonisolated\s+)*(?:func|var)\s+(\w+)"#)
    func firstMatch(_ regex: NSRegularExpression, _ line: String) -> String? {
        guard let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else { return nil }
        return String(line[Range(match.range(at: 1), in: line)!])
    }
    return paths.map { relative in
        let path = "\(directory)/\(relative)"
        let text = (try? String(contentsOf: base.appendingPathComponent(relative), encoding: .utf8)) ?? ""
        var lines: [String] = []
        var types = Set<String>(), members = Set<String>()
        var inExtension = false
        for line in text.components(separatedBy: "\n") {
            if line.hasPrefix("#Preview") { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") { continue }
            lines.append(line)
            if line.hasPrefix("extension ") || line.hasPrefix("public extension ") { inExtension = true }
            if line == "}" { inExtension = false }
            if let name = firstMatch(typePattern, line) { types.insert(name) }
            if inExtension, let name = firstMatch(memberPattern, line) { members.insert(name) }
        }
        return ScannedFile(path: path, code: lines.joined(separator: "\n"), types: types, members: members)
    }
}

let libraryFiles = scanModule("Sources/MotionLibrary")

/// Other `MotionLibrary` files an effect's source needs to compile on its own
/// (shared helpers in `Support/`, or another effect it builds on), found by
/// looking for types and extension members declared elsewhere. Transitive.
func dependencies(of effect: MotionEffect) -> [String] {
    var needed: [String] = []
    var queue = [effect.sourcePath]
    while let path = queue.popLast() {
        guard let file = libraryFiles.first(where: { $0.path == path }) else { continue }
        for other in libraryFiles where other.path != path && other.path != effect.sourcePath && !needed.contains(other.path) {
            let usesType = other.types.contains { file.code.range(of: #"\b\#($0)\b"#, options: .regularExpression) != nil && !file.types.contains($0) }
            let usesMember = other.members.contains { file.code.range(of: #"\.\#($0)\b"#, options: .regularExpression) != nil && !file.members.contains($0) }
            if usesType || usesMember {
                needed.append(other.path)
                queue.append(other.path)
            }
        }
    }
    return needed.sorted()
}

/// File names of the extra files an effect needs (helpers and shaders).
func extraFileNames(_ effect: MotionEffect) -> [String] {
    files(of: effect).dropFirst().map { ($0 as NSString).lastPathComponent }
}

/// The effect's own file followed by every file it needs, in copy order.
func files(of effect: MotionEffect) -> [String] {
    [effect.sourcePath] + dependencies(of: effect) + (effect.shaderPath.map { [$0] } ?? [])
}

func source(of effect: MotionEffect) -> String {
    var text = read(effect.sourcePath, for: effect)
    for path in dependencies(of: effect) {
        text += "\n\n// MARK: - \((path as NSString).lastPathComponent)\n// Needed by this effect: save it as its own file next to the one above.\n\n" + read(path, for: effect)
    }
    // Shader effects: the Metal file goes with the Swift file.
    if let shader = effect.shaderPath {
        let name = (shader as NSString).lastPathComponent
        text += "\n\n// MARK: - \(name)\n// Save the shader below as \(name) in your app target, and replace\n// `motionShaders` with `ShaderLibrary.default`.\n/*\n" + read(shader, for: effect) + "\n*/"
    }
    return text
}

func sourceURL(_ effect: MotionEffect) -> String {
    "\(repoURL)/blob/main/\(effect.sourcePath)"
}

func triggers(_ effect: MotionEffect) -> String {
    effect.triggers.map(\.title).joined(separator: " / ")
}

func html(_ text: String) -> String {
    text.replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}

/// The current release. Bump it together with the git tag.
let packageVersion = "0.6.0"

let installSnippet = """
    ```swift
    // Package.swift
    .package(url: "\(repoURL)", from: "\(packageVersion)")
    // target dependencies
    .product(name: "MotionLibrary", package: "SwiftUI-Motion-Library")
    ```

    Then `import MotionLibrary`. Requires iOS 17, macOS 14 or visionOS 1; effects marked iOS 18+ are `@available(iOS 18, macOS 15, visionOS 2, *)`.

    In an Xcode app project, add the package with **File → Add Package Dependencies…** rather than editing `project.pbxproj` by hand. To use one effect without the package, copy its source file plus any files listed under "Files" for it (shared helpers such as `Support/Haptics.swift`); every effect compiles from just those files.
    """

/// Markdown table of every effect, grouped by component.
func effectTable(linkSource: Bool) -> String {
    var lines: [String] = []
    for group in groups {
        lines.append("### \(group.component.title)")
        lines.append("")
        lines.append("| Effect | API | Trigger | Use it for |")
        lines.append("|---|---|---|---|")
        for effect in group.effects {
            let name = linkSource ? "[\(effect.name)](\(sourceURL(effect)))" : effect.name
            let requirement = effect.requirement == .ios17 ? "" : " (\(effect.requirement.title))"
            let api = effect.api.replacingOccurrences(of: "|", with: "\\|")
            lines.append("| \(name)\(requirement) | `\(api)` | \(triggers(effect)) | \(effect.summary) |")
        }
        lines.append("")
    }
    return lines.joined(separator: "\n")
}

// MARK: - Outputs

/// GitHub's heading anchor: lowercased, punctuation dropped, spaces to hyphens
/// ("Card & Group" → "card--group", "粒子與 3D" → "粒子與-3d").
func githubAnchor(_ heading: String) -> String {
    heading.lowercased()
        .filter { $0.isLetter || $0.isNumber || $0 == " " || $0 == "-" }
        .replacingOccurrences(of: " ", with: "-")
}

/// Icon for a component's card in the README jump index.
func readmeEmoji(_ component: MotionComponent) -> String {
    switch component {
    case .text: "🔤"
    case .button: "🔘"
    case .card: "🃏"
    case .shape: "🔷"
    case .background: "🌈"
    case .number: "🔢"
    case .particle: "✨"
    case .transition: "🎬"
    case .shader: "🪄"
    }
}

/// The languages the README is published in. Only the effects section is
/// generated; the prose around it is maintained by hand in each file.
enum ReadmeLanguage {
    case english, traditionalChinese

    /// Lead-in to the extra files an effect needs without the package.
    var copyLabel: String {
        switch self {
        case .english: "Copying the file? Also copy"
        case .traditionalChinese: "直接複製檔案時，還需要"
        }
    }

    var file: String {
        switch self {
        case .english: "README.md"
        case .traditionalChinese: "README.zh-TW.md"
        }
    }

    func title(_ component: MotionComponent) -> String {
        guard self == .traditionalChinese else { return component.title }
        switch component {
        case .text: return "文字"
        case .button: return "按鈕"
        case .card: return "卡片與群組"
        case .shape: return "圖形"
        case .background: return "背景"
        case .number: return "數字"
        case .particle: return "粒子與 3D"
        case .transition: return "轉場"
        case .shader: return "著色器"
        }
    }

    func title(_ trigger: MotionTrigger) -> String {
        guard self == .traditionalChinese else { return trigger.title }
        switch trigger {
        case .appear: return "進場"
        case .tap: return "點擊"
        case .press: return "按壓"
        case .drag: return "拖曳"
        case .hover: return "懸停"
        case .scroll: return "捲動"
        case .change: return "數值改變"
        case .loop: return "循環"
        }
    }

    func count(_ n: Int) -> String {
        switch self {
        case .english: "\(n) \(n == 1 ? "effect" : "effects")"
        case .traditionalChinese: "\(n) 個效果"
        }
    }

    func summary(effects: Int, categories: Int) -> String {
        switch self {
        case .english: "<b>\(effects) effects</b> in \(categories) categories"
        case .traditionalChinese: "共 <b>\(effects) 個效果</b>，分為 \(categories) 類"
        }
    }
}

/// Under the API: the extra files to copy when not using the package.
func copyNote(_ effect: MotionEffect, _ language: ReadmeLanguage) -> String {
    let extra = dependencies(of: effect) + (effect.shaderPath.map { [$0] } ?? [])
    guard !extra.isEmpty else { return "" }
    let links = extra.map { "<a href=\"\(repoURL)/blob/main/\($0)\">\(($0 as NSString).lastPathComponent)</a>" }
    return "<br><sub>\(language.copyLabel) \(links.joined(separator: ", "))</sub>"
}

/// One 3-column table of GIF cells.
func gifTable(_ group: [MotionEffect], _ language: ReadmeLanguage) -> String {
    var rows: [String] = []
    for start in stride(from: 0, to: group.count, by: 3) {
        let cells = group[start..<min(start + 3, group.count)].map { effect in
            let requirement = effect.requirement == .ios17 ? "" : " · \(effect.requirement.title)"
            let triggers = effect.triggers.map { language.title($0) }.joined(separator: " / ")
            return """
                <td align="center" valign="top" width="33%">
                <img src="Docs/gifs/\(effect.id).gif" width="240" alt="\(html(effect.name))"><br>
                <a href="\(sourceURL(effect))"><b>\(html(effect.name))</b></a><br>
                <sub>\(html(triggers))\(requirement)</sub><br>
                <code>\(html(effect.api))</code>\(copyNote(effect, language))
                </td>
                """
        }
        rows.append("<tr>\n" + cells.joined(separator: "\n") + "\n</tr>")
    }
    return "<table>\n" + rows.joined(separator: "\n") + "\n</table>"
}

/// The README effects section: a jump index, then one heading and table per
/// component, in `MotionComponent` order (catalog order within each).
func readmeGrid(_ language: ReadmeLanguage) -> String {
    // Jump index: a centred 4-column table of category cards.
    let indexCells = groups.map { component, members in
        let title = language.title(component)
        return """
            <td align="center" width="25%">
            \(readmeEmoji(component))<br>
            <a href="#\(githubAnchor(title))"><b>\(html(title))</b></a><br>
            <sub>\(language.count(members.count))</sub>
            </td>
            """
    }
    let indexRows = stride(from: 0, to: indexCells.count, by: 4).map { start in
        "<tr>\n" + indexCells[start..<min(start + 4, indexCells.count)].joined(separator: "\n") + "\n</tr>"
    }
    let sections = groups.map { component, members in
        "### \(language.title(component))\n\n" + gifTable(members, language)
    }
    return """
        <!-- effects:start (generated by Scripts/generate-docs.sh; edit MotionCatalog.swift instead) -->
        <p align="center">\(language.summary(effects: effects.count, categories: groups.count))</p>

        <table align="center">
        \(indexRows.joined(separator: "\n"))
        </table>

        \(sections.joined(separator: "\n\n"))
        <!-- effects:end -->
        """
}

func llmsTxt() -> String {
    var lines = [
        "# SwiftUI Motion Library",
        "",
        "> \(effects.count) copy-paste SwiftUI motion effects (text, buttons, cards, shapes, loaders, backgrounds, particles and 3D) as small, dependency-free views and modifiers. Effects with large or looping motion respect Reduce Motion.",
        "",
        "Use the library API instead of hand-writing these animations. Install with Swift Package Manager:",
        "",
        installSnippet,
        "",
    ]
    for group in groups {
        lines.append("## \(group.component.title)")
        lines.append("")
        for effect in group.effects {
            let requirement = effect.requirement == .ios17 ? "" : " Requires \(effect.requirement.title)."
            let extra = extraFileNames(effect)
            let copy = extra.isEmpty ? "" : " Copying it without the package also needs \(extra.map { "`\($0)`" }.joined(separator: ", "))."
            lines.append("- [\(effect.name)](\(sourceURL(effect))): \(effect.summary) API: `\(effect.api)`. Trigger: \(triggers(effect)).\(requirement)\(copy)")
        }
        lines.append("")
    }
    lines += [
        "## Reference",
        "",
        "- [llms-full.txt](\(rawURL)/llms-full.txt): usage, implementation notes and full source of every effect",
        "- [motion-catalog.json](\(rawURL)/Docs/motion-catalog.json): the same data as JSON",
        "- [MCP server](\(repoURL)/tree/main/mcp): search effects and fetch their code from any MCP client",
        "",
    ]
    return lines.joined(separator: "\n")
}

func llmsFullTxt() -> String {
    var parts = [
        """
        # SwiftUI Motion Library: full reference

        > Every effect with its API, usage, an implementation description and the complete source. Generated from the catalog; \(effects.count) effects.

        ## Install

        \(installSnippet)
        """,
    ]
    for effect in effects {
        parts.append("""
            ---

            ## \(effect.name) (`\(effect.id)`)

            \(effect.summary)

            - API: `\(effect.api)`
            - Component: \(effect.component.title)
            - Trigger: \(triggers(effect))
            - Requires: \(effect.requirement.platforms)
            - Source: \(sourceURL(effect))
            - Files: \(files(of: effect).joined(separator: ", "))

            ### Usage

            ```swift
            \(effect.usage)
            ```

            ### How it works

            \(effect.prompt)

            ### Source

            ```swift
            \(source(of: effect))
            ```
            """)
    }
    return parts.joined(separator: "\n\n") + "\n"
}

struct CatalogEntry: Encodable {
    let id: String
    let name: String
    let summary: String
    let component: String
    let componentTitle: String
    let triggers: [String]
    let requirement: String
    let platforms: String
    let api: String
    let usage: String
    let prompt: String
    let sourceFile: String
    /// Every file to copy to use the effect without the package, own file first.
    let files: [String]
    let sourceURL: String
    let gifURL: String
    let source: String
}

struct Catalog: Encodable {
    let name = "SwiftUI Motion Library"
    let repository = repoURL
    let install: String
    let effects: [CatalogEntry]
}

func catalogJSON() -> String {
    let catalog = Catalog(
        install: installSnippet,
        effects: effects.map { effect in
            CatalogEntry(
                id: effect.id,
                name: effect.name,
                summary: effect.summary,
                component: effect.component.rawValue,
                componentTitle: effect.component.title,
                triggers: effect.triggers.map(\.rawValue),
                requirement: effect.requirement.title,
                platforms: effect.requirement.platforms,
                api: effect.api,
                usage: effect.usage,
                prompt: effect.prompt,
                sourceFile: effect.sourcePath,
                files: files(of: effect),
                sourceURL: sourceURL(effect),
                gifURL: "\(rawURL)/Docs/gifs/\(effect.id).gif",
                source: source(of: effect)
            )
        }
    )
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    return String(decoding: try! encoder.encode(catalog), as: UTF8.self) + "\n"
}

let skillDescription = "Adds polished SwiftUI animations from SwiftUI Motion Library: animated text, button micro-interactions, card transitions, loaders, confetti, animated backgrounds, particles and 3D effects. Use when building or improving SwiftUI UI that needs animation, transitions, loading or success states, celebratory feedback, or a moving background."

let usageRules = """
    ## How to use

    1. Pick the effect from the table that matches what the UI needs. Prefer the library API over hand-writing the animation.
    2. Add the package if the project doesn't have it yet (in an Xcode app project, ask the user to use **File → Add Package Dependencies…** instead of editing `project.pbxproj`), and `import MotionLibrary`. If the user wants no dependency, copy the effect's files instead: its own source plus the helpers listed for it in `Docs/motion-catalog.json` (`files`) or llms-full.txt ("Files").
    3. Copy the usage for that effect from `references/effects.md` (or \(rawURL)/llms-full.txt) and adapt colours, sizes and timing through the parameters.
    4. Effects marked iOS 18+ need `if #available(iOS 18, macOS 15, visionOS 2, *)` when the app targets an older OS.
    5. Effects with large or looping motion already honour Reduce Motion (they pause, fade or drop the movement), so don't wrap them in your own check.
    6. If no effect fits, adapt the closest one: its "How it works" note describes the technique.
    """

func skill() -> String {
    """
    ---
    name: swiftui-motion
    description: "\(skillDescription)"
    ---

    # SwiftUI Motion Library

    \(effects.count) ready-made SwiftUI motion effects as one-line views and modifiers, with no dependencies. Source: \(repoURL)

    ## Install

    \(installSnippet)

    \(usageRules)

    ## Effects

    \(effectTable(linkSource: false))
    """
}

func skillReference() -> String {
    var parts = ["# Effect reference\n\nUsage and implementation notes for every effect. Full source: \(rawURL)/llms-full.txt"]
    for effect in effects {
        parts.append("""
            ## \(effect.name)

            \(effect.summary) Trigger: \(triggers(effect)). Requires \(effect.requirement.title). Files: \(files(of: effect).joined(separator: ", ")).

            ```swift
            \(effect.usage)
            ```

            How it works: \(effect.prompt)
            """)
    }
    return parts.joined(separator: "\n\n") + "\n"
}

func cursorRule() -> String {
    """
    ---
    description: "\(skillDescription)"
    globs: "**/*.swift"
    alwaysApply: false
    ---

    # SwiftUI Motion Library

    When SwiftUI code needs animation, use these ready-made effects from `MotionLibrary` (\(repoURL)) instead of writing the animation by hand.

    ## Install

    \(installSnippet)

    \(usageRules.replacingOccurrences(of: "from `references/effects.md` (or \(rawURL)/llms-full.txt)", with: "from \(rawURL)/llms-full.txt"))

    ## Effects

    \(effectTable(linkSource: true))
    """
}

// MARK: - Write or check

var stale: [String] = []

func emit(_ relativePath: String, _ content: String) {
    let url = root.appendingPathComponent(relativePath)
    let existing = try? String(contentsOf: url, encoding: .utf8)
    guard existing != content else { return }
    stale.append(relativePath)
    guard !checkOnly else { return }
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try! content.write(to: url, atomically: true, encoding: .utf8)
}

func replacingReadmeGrid(in readme: String, _ language: ReadmeLanguage) -> String {
    guard let start = readme.range(of: "<!-- effects:start"),
          let end = readme.range(of: "<!-- effects:end -->") else {
        fatalError("\(language.file) is missing the <!-- effects:start --> / <!-- effects:end --> markers")
    }
    return readme.replacingCharacters(in: start.lowerBound..<end.upperBound, with: readmeGrid(language))
}

let ids = effects.map(\.id)
if Set(ids).count != ids.count {
    fatalError("duplicate catalog ids: \(ids.filter { id in ids.filter { $0 == id }.count > 1 })")
}
for effect in effects where effect.api.isEmpty {
    fatalError("\(effect.id) has no `api` in MotionCatalog.swift")
}
// The README shows `api` in <code> under a 240 pt GIF. Code doesn't wrap
// (and GitHub strips <wbr>), so a run without spaces wider than the GIF
// widens its column and pushes the table off the page.
let maxAPIRun = 30
for effect in effects {
    let longest = effect.api.split(separator: " ").map(\.count).max() ?? 0
    if longest > maxAPIRun {
        fatalError("\(effect.id): `api` has \(longest) characters without a space (max \(maxAPIRun)), which breaks the README grid. Use the trailing-closure form, e.g. \"Name(items) { item in }\".")
    }
}

for language in [ReadmeLanguage.english, .traditionalChinese] {
    let readme = try! String(contentsOf: root.appendingPathComponent(language.file), encoding: .utf8)
    emit(language.file, replacingReadmeGrid(in: readme, language))
}
emit("llms.txt", llmsTxt())
emit("llms-full.txt", llmsFullTxt())
emit("Docs/motion-catalog.json", catalogJSON())
emit("skills/swiftui-motion/SKILL.md", skill())
emit("skills/swiftui-motion/references/effects.md", skillReference())
emit(".cursor/rules/swiftui-motion.mdc", cursorRule())

let missingGIFs = effects.filter {
    !FileManager.default.fileExists(atPath: root.appendingPathComponent("Docs/gifs/\($0.id).gif").path)
}.map(\.id)
if !missingGIFs.isEmpty {
    print("missing GIFs (run Scripts/record-readme-gifs.sh \(missingGIFs.joined(separator: " "))): \(missingGIFs.joined(separator: ", "))")
}

if checkOnly {
    if stale.isEmpty && missingGIFs.isEmpty {
        print("generated docs are up to date")
    } else {
        if !stale.isEmpty { print("out of date (run Scripts/generate-docs.sh): \(stale.joined(separator: ", "))") }
        exit(1)
    }
} else {
    print(stale.isEmpty ? "nothing to update" : "updated: \(stale.joined(separator: ", "))")
}
