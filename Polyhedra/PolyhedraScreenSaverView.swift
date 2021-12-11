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
            velocity = CGVector(dx: 7, dy: 7)
        } else {
            radius = 150
            velocity = CGVector(dx: 15, dy: 15)
        }
        // make sure polyhedron (2 * radius in width) does not got off screen
        maxX = frame.width - 2 * radius
        maxY = frame.height - 2 * radius
        // place at a random point in the frame
        position.x = CGFloat.random(in: 0 ..< maxX)
        position.y = CGFloat.random(in: 0 ..< maxY)
        animationTimeInterval = 1.0 / 20
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
        let cachedRenderings = settings.getPolyhedron().generateCachedRenderings(color: settings.fixedColor)
        polyhedronView = PolyhedronView(origin: position, radius: radius, cachedRenderings: cachedRenderings)
        addSubview(polyhedronView!)
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
        polyhedronView!.setFrameOrigin(position)
        polyhedronView!.rotate()
    }
}
