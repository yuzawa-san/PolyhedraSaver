import ScreenSaver

class PolyhedraScreenSaverView: ScreenSaverView {
    private var position: CGPoint = .zero
    private var velocity: CGVector = .zero
    private var radius: CGFloat = .zero
    private var maxX: CGFloat = .zero
    private var maxY: CGFloat = .zero
    private lazy var sheetController = ConfigSheetController()
    private var settings = PolyhedraSettings()
    private var polyhedronView: PolyhedronView?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        if isPreview {
            radius = 25
            velocity = CGVector(dx: 6, dy: 6)
        } else {
            radius = 150
            velocity = CGVector(dx: 12, dy: 12)
        }
        // make sure polyhedron (2 * radius in width) does not got off screen
        maxX = frame.width - 2 * radius
        maxY = frame.height - 2 * radius
        // place at a random point in the frame
        position.x = CGFloat.random(in: 0 ..< maxX)
        position.y = CGFloat.random(in: 0 ..< maxY)
        animationTimeInterval = 1.0 / 25
    }

    override func startAnimation() {
        settings = PolyhedraSettings()
        if settings.shouldShowPolyhedronName() {
            let fontSize: CGFloat = isPreview ? 5 : 24
            // configure text
            let font = NSFont.systemFont(ofSize: fontSize)
            let textRect = NSRect(x: fontSize, y: fontSize, width: frame.width, height: fontSize * 1.5)
            let color = NSColor(calibratedWhite: 1.0, alpha: 0.2)
            let labelView = NSTextField(frame: textRect)
            addSubview(labelView)
            labelView.font = font
            labelView.isBezeled = false
            labelView.isSelectable = false
            labelView.drawsBackground = false
            labelView.textColor = color
            labelView.stringValue = settings.getPolyhedron().name
        }
        let cachedRenderings = settings.getPolyhedron().generateCachedRenderings(
            radius: radius,
            color: settings.fixedColor)
        polyhedronView = PolyhedronView(origin: position, radius: radius, cachedRenderings: cachedRenderings)
        addSubview(polyhedronView!)
        super.startAnimation()
    }

    override func stopAnimation() {
        for view in subviews {
            view.removeFromSuperview()
        }
        super.stopAnimation()
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

    override func animateOneFrame() {
        super.animateOneFrame()
        // update object position
        let drawingRect = polyhedronView!.getDrawBounds()
        let positionX = position.x + velocity.dx
        let leftX = positionX + drawingRect.minX
        let rightX = positionX - 2 * radius + drawingRect.maxX
        if leftX < 0 || rightX > maxX {
            velocity.dx *= -1
        }
        position.x += velocity.dx
        let positionY = position.y + velocity.dy
        let bottomY = positionY + drawingRect.minY
        let topY = positionY - 2 * radius + drawingRect.maxY
        if bottomY < 0 || topY > maxY {
            velocity.dy *= -1
        }
        position.y += velocity.dy
        polyhedronView!.setFrameOrigin(position)
        polyhedronView!.rotate()
    }
}
