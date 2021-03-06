import ScreenSaver

class PolyhedraScreenSaverView: ScreenSaverView {
    private var position: CGPoint = .zero
    private var velocity: CGVector = .zero
    private var radius: CGFloat = .zero
    private var maxX: CGFloat = .zero
    private var maxY: CGFloat = .zero
    private var rotation: Int = .zero
    private lazy var sheetController = ConfigSheetController()
    private var cachedRenderings: [CachedRendering] = []
    private var settings = PolyhedraSettings()
    private var textRect: NSRect = .zero
    private var textAttributes: [NSAttributedString.Key: Any] = .init()

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        var fontSize: CGFloat = 24
        if isPreview {
            radius = 25
            velocity = CGVector(dx: 5, dy: 5)
            fontSize = 5
        } else {
            radius = 150
            velocity = CGVector(dx: 10, dy: 10)
        }
        // make sure polyhedron (2 * radius in width) does not got off screen
        maxX = frame.width - 2 * radius
        maxY = frame.height - 2 * radius
        // place at a random point in the frame
        position.x = CGFloat.random(in: 0 ..< maxX)
        position.y = CGFloat.random(in: 0 ..< maxY)
        // configure text
        let font = NSFont.systemFont(ofSize: fontSize)
        textRect = NSRect(x: fontSize, y: fontSize, width: frame.width, height: fontSize * 1.5)
        let color = NSColor(calibratedWhite: 1.0, alpha: 0.2)
        textAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        animationTimeInterval = 1.0 / 30
    }

    override func startAnimation() {
        settings = PolyhedraSettings()
        cachedRenderings = settings.getPolyhedron().generateCachedRenderings(color: settings.fixedColor)
        super.startAnimation()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        return sheetController.window
    }

    override func draw(_: NSRect) {
        // clear the screen
        NSColor.black.setFill()
        bounds.fill()
        if cachedRenderings.isEmpty {
            // we have not loaded the settings yet
            return
        }
        // fetch a cached rendering
        let cachedRendering = cachedRenderings[rotation]
        cachedRendering.render(position: position, radius: radius, lineWidth: 1)
        // draw polyhedron name
        if settings.shouldShowPolyhedronName() {
            settings.getPolyhedron().name.draw(in: textRect, withAttributes: textAttributes)
        }
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        // update object position
        position.x += velocity.dx
        let positionX = position.x
        if positionX < 0 || positionX > maxX {
            velocity.dx *= -1
        }
        position.y += velocity.dy
        let positionY = position.y
        if positionY < 0 || positionY > maxY {
            velocity.dy *= -1
        }
        // update object rotation
        rotation = (rotation + 1) % cachedRenderings.count
        needsDisplay = true
    }
}
