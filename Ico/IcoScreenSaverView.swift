import ScreenSaver

class IcoScreenSaverView: ScreenSaverView {
    private var position: CGPoint = .zero
    private var velocity: CGVector = .zero
    private var radius: CGFloat = .zero
    private var maxX: CGFloat = .zero
    private var maxY: CGFloat = .zero
    private var rotation: Int = .zero
    private var cachedRenderings = [CachedRendering]()
    lazy var sheetController = ConfigSheetController()
    private let defaultsManager = DefaultsManager()
    private var colorOverride: NSColor?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        if isPreview {
            radius = 25
            velocity = CGVector(dx: 5, dy: 5)
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
        animationTimeInterval = 1.0 / 30
    }

    override func startAnimation() {
        // load cached renderings and color
        cachedRenderings = PolyhedraRegistry.forName(name: defaultsManager.polyhedronName).generateCachedRenderings()
        if defaultsManager.useColorOverride {
            colorOverride = defaultsManager.colorOverride
        } else {
            colorOverride = nil
        }
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
        // place points on screen relative to object position
        let points = cachedRendering.points.map { CGPoint(
            x: CGFloat(position.x + radius + radius * $0.x),
            y: CGFloat(position.y + radius - radius * $0.y)
        ) }
        // draw edges
        let path = NSBezierPath()
        for edge in cachedRendering.edges {
            let startPoint = points[edge.startPointIdx]
            let endPoint = points[edge.endPointIdx]
            path.move(to: startPoint)
            path.line(to: endPoint)
        }
        (colorOverride ?? cachedRendering.color).set()
        path.lineWidth = 1
        path.stroke()
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
