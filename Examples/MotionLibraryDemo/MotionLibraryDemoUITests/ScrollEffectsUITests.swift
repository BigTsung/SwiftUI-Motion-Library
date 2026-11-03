import XCTest

/// Scrolls each scroll-driven effect with real finger drags, which the
/// off-screen macOS GIF recorder can't do. Screenshots of every step are
/// attached to the test result (open the .xcresult in Xcode to see them).
final class ScrollEffectsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func launch(_ example: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["SCROLL_EXAMPLE"] = example
        app.launch()
        return app
    }

    /// A slow drag that holds before lifting, so the scroll view doesn't fling.
    private func drag(_ app: XCUIApplication, from start: CGFloat, to end: CGFloat, hold: TimeInterval = 0.3) {
        let window = app.windows.firstMatch
        let from = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: start))
        let to = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: end))
        from.press(forDuration: 0.05, thenDragTo: to, withVelocity: .slow, thenHoldForDuration: hold)
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func scrollAndCapture(_ example: String, steps: Int = 4, check: ((XCUIApplication, Int) -> Void)? = nil) {
        let app = launch(example)
        attachScreenshot("\(example) 0")
        for step in 1...steps {
            drag(app, from: 0.7, to: 0.45)
            attachScreenshot("\(example) \(step)")
            check?(app, step)
        }
    }

    private func element(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    /// How far one `drag` scrolls, in points.
    private func dragDistance(_ app: XCUIApplication) -> CGFloat {
        app.windows.firstMatch.frame.height * 0.25
    }

    func testStackingCards() {
        let app = launch("stacking-cards")
        let card = element(app, "card-0")
        let initial = card.frame
        attachScreenshot("stacking-cards 0")
        for step in 1...4 {
            drag(app, from: 0.7, to: 0.45)
            attachScreenshot("stacking-cards \(step)")
            if step <= 2 {
                // Without the effect the first card would have scrolled off
                // the top by now; stuck near the pin line it is still in view.
                XCTAssertGreaterThan(card.frame.maxY, 50, "first card should stick at the top (step \(step))")
                XCTAssertLessThan(card.frame.width, initial.width - 10, "a covered card should shrink (step \(step))")
            }
        }
    }

    func testShrinkingHeader() {
        let app = launch("shrinking-header")
        let header = element(app, "header")
        let initial = header.frame
        attachScreenshot("shrinking-header 0")
        for step in 1...4 {
            drag(app, from: 0.7, to: 0.45)
            attachScreenshot("shrinking-header \(step)")
            let frame = header.frame
            XCTAssertEqual(frame.minY, initial.minY, accuracy: 2, "header should stay pinned at the top (step \(step))")
            XCTAssertLessThan(frame.width, initial.width * 0.75, "header should shrink (step \(step))")
            XCTAssertGreaterThan(frame.width, initial.width * 0.55, "header should stop at minScale (step \(step))")
        }
    }

    func testStretchyHeader() {
        let app = launch("stretchy-header")
        let header = element(app, "header")
        let initial = header.frame
        attachScreenshot("stretchy-header 0")
        drag(app, from: 0.7, to: 0.45)
        attachScreenshot("stretchy-header scrolled")
        // Parallax: the header moves up at half the scroll speed.
        let moved = initial.minY - header.frame.minY
        XCTAssertEqual(moved, dragDistance(app) * 0.5, accuracy: dragDistance(app) * 0.15, "header should drift at half speed")
    }

    func testReadingProgress() {
        // The bar is hidden from accessibility, so this one is checked by eye:
        // the screenshots should show the pink bar growing along the top.
        scrollAndCapture("reading-progress")
    }
}
