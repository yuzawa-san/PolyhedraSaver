import AppKit

class PolyhedraFullLayer: CALayer {
    private let polyhedronLayer: PolyhedronView
    private let cachedRenderings: [CachedRendering]
    private let radius: CGFloat
    private let maxX: CGFloat
    private let maxY: CGFloat
    private var polyhedronPosition: CGPoint = .zero
    private var velocity: CGVector = .zero
    private var rotation: Int = .zero

    public init(size: CGSize, isPreview: Bool) {
        let settings = PolyhedraSettings()
        self.polyhedronLayer = PolyhedronView(lineWidth: 1)
        self.radius = isPreview ? 25 : 150
        self.velocity = isPreview ? CGVector(dx: 6, dy: 6) : CGVector(dx: 12, dy: 12)
        // make sure polyhedron (2 * radius in width) does not got off screen
        self.maxX = size.width - 2 * radius
        self.maxY = size.height - 2 * radius
        // place at a random point in the frame
        polyhedronPosition.x = CGFloat.random(in: 0 ..< maxX)
        polyhedronPosition.y = CGFloat.random(in: 0 ..< maxY)
        self.polyhedronLayer.frame = CGRect(origin: polyhedronPosition,
                                            size: CGSize(width: radius * 2, height: radius * 2))
        let polyhedron = settings.getPolyhedron()
        self.cachedRenderings = polyhedron.generateCachedRenderings(
            radius: radius,
            color: settings.fixedColor)
        super.init()
        let scale = NSScreen.main!.backingScaleFactor
        if settings.shouldShowPolyhedronName() {
            let fontSize: CGFloat = isPreview ? 5 : 24
            // configure text
            let font = NSFont.systemFont(ofSize: fontSize)
            let textLayer = CATextLayer()
            textLayer.contentsScale = scale
            textLayer.frame = CGRect(x: fontSize, y: fontSize, width: size.width, height: fontSize * 1.5)
            textLayer.font = font
            textLayer.fontSize = fontSize
            textLayer.alignmentMode = .left
            textLayer.string = polyhedron.name
            textLayer.backgroundColor = CGColor.clear
            textLayer.foregroundColor = CGColor.init(gray: 1.0, alpha: 0.2)
            addSublayer(textLayer)
        }
        addSublayer(polyhedronLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animateOneFrame() {
        // update object position
        let rendering = cachedRenderings[rotation]
        let boundingBox = rendering.boundingBox
        let positionX = polyhedronPosition.x + velocity.dx
        let left = positionX + boundingBox.left
        let right = positionX - boundingBox.right
        if left < 0 || right > maxX {
            velocity.dx *= -1
        }
        polyhedronPosition.x += velocity.dx
        let positionY = polyhedronPosition.y + velocity.dy
        let bottom = positionY + boundingBox.bottom
        let top = positionY - boundingBox.top
        if bottom < 0 || top > maxY {
            velocity.dy *= -1
        }
        polyhedronPosition.y += velocity.dy
        rotation = (rotation + 1) % cachedRenderings.count
        polyhedronLayer.setRendering(position: polyhedronPosition, rendering: rendering)
    }

}
