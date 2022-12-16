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
    private var rotation: Int = .zero
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
        wantsLayer = true
    }

    override func startAnimation() {
        settings = PolyhedraSettings()
        if settings.shouldShowPolyhedronName() {
            let fontSize: CGFloat = isPreview ? 5 : 24
            // configure text
            let font = NSFont.systemFont(ofSize: fontSize)
            let textLayer = CATextLayer()
            textLayer.contentsScale = NSScreen.main!.backingScaleFactor
            textLayer.frame = CGRect(x: fontSize, y: fontSize, width: frame.width, height: fontSize * 1.5)
            textLayer.font = font
            textLayer.fontSize = fontSize
            textLayer.alignmentMode = .left
            textLayer.string = settings.getPolyhedron().name
            textLayer.backgroundColor = CGColor.clear
            textLayer.foregroundColor = CGColor.init(gray: 1.0, alpha: 0.2)
            layer?.addSublayer(textLayer)
        }
        self.cachedRenderings = settings.getPolyhedron().generateCachedRenderings(
            radius: radius,
            color: settings.fixedColor)
        polyhedronView = PolyhedronView(lineWidth: 1)
        layer?.addSublayer(polyhedronView!)
        super.startAnimation()
    }

    override func stopAnimation() {
        polyhedronView = nil
        layer?.sublayers?.removeAll()
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
        polyhedronView!.setRendering(position: position, rendering: rendering)
    }
}
