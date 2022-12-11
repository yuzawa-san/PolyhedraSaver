import ScreenSaver

class PolyhedraScreenSaverView: ScreenSaverView {
    private var position: CGPoint = .zero
    private var velocity: CGVector = .zero
    private var radius: CGFloat = .zero
    private var maxX: CGFloat = .zero
    private var maxY: CGFloat = .zero
    private lazy var sheetController = ConfigSheetController()
    private var settings = PolyhedraSettings()
    private var rotation: Int = .zero
    private var polyhedronView: NSImageView?
    private var cachedRenderings: [CachedRendering] = []

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
        cachedRenderings = settings.getPolyhedron().generateCachedRenderings(
            radius: radius, lineWidth: 1,
            color: settings.fixedColor)
        polyhedronView = NSImageView(frame: NSRect(origin: position,
                                                   size: NSSize(width: 2 * radius, height: 2 * radius)))
        polyhedronView?.imageScaling = .scaleNone
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
        let rendering = cachedRenderings[rotation]
        let boundingBox = rendering.boundingBox
        let positionX = position.x + velocity.dx
        let left = positionX + boundingBox.left
        let right = positionX - boundingBox.right
        if left < 0 || right > maxX {
            velocity.dx *= -1
        }
        position.x += velocity.dx
        let positionY = position.y + velocity.dy
        let bottom = positionY + boundingBox.bottom
        let top = positionY - boundingBox.top
        if bottom < 0 || top > maxY {
            velocity.dy *= -1
        }
        position.y += velocity.dy
        polyhedronView!.setFrameOrigin(position)
        rotation = (rotation + 1) % cachedRenderings.count
        polyhedronView!.image = rendering.image
    }
}
