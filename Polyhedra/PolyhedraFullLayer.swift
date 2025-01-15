import AppKit

class PolyhedraFullLayer: CALayer {
    static let fpsSlow: Int = 24
    static let fpsFast: Int = 48
    static let rotationSeconds: Int = 15
    static let degrees: Int = 360

    private let polyhedraLayer: CALayer
    private let cachedRenderings: ContiguousArray<CachedRendering>
    private let radius: Int
    private let maxX: Int
    private let maxY: Int
    private let framesPerDegree: Int
    private var positionX: Int = .zero
    private var positionY: Int = .zero
    private var velocityX: Int = .zero
    private var velocityY: Int = .zero
    private var rotation: Int = .zero
    private var frameNumber: Int = .zero

    public init(size: CGSize, fps: Int, isPreview: Bool) {
        let settings = PolyhedraSettings()
        self.polyhedraLayer = CALayer()
        self.polyhedraLayer.isOpaque = true
        self.framesPerDegree = fps * PolyhedraFullLayer.rotationSeconds / PolyhedraFullLayer.degrees
        self.radius = Int(min(size.width, size.height) * 0.125)
        self.velocityX = max(1, radius / fps * 2)
        self.velocityY = velocityX
        // make sure polyhedron (2 * radius in width) does not got off screen
        self.maxX = Int(size.width) - 2 * radius
        self.maxY = Int(size.height) - 2 * radius
        // place at a random point in the frame
        self.positionX = Int.random(in: 0 ..< maxX)
        self.positionY = Int.random(in: 0 ..< maxY)
        self.polyhedraLayer.frame = CGRect(x: positionX, y: positionY, width: radius * 2, height: radius * 2)
        let polyhedron = settings.getPolyhedron()
        self.cachedRenderings = polyhedron.generateCachedRenderings(
            radius: radius, lineWidth: 1,
            color: settings.fixedColor)
        super.init()
        self.isOpaque = true
        addSublayer(polyhedraLayer)
        if !isPreview {
            let textOffset = CGFloat(radius) * 0.1
            if settings.shouldShowPolyhedronName() {
                let textLayer = PolyhedraFullLayer.newTextLayer(content: polyhedron.name)
                let sourceFrame = textLayer.frame
                textLayer.frame = sourceFrame.offsetBy(dx: textOffset, dy: textOffset)
                addSublayer(textLayer)
            }
            if settings.showComputerName {
                let hostname = Host.current().localizedName ?? ""
                let textLayer = PolyhedraFullLayer.newTextLayer(content: hostname)
                let sourceFrame = textLayer.frame
                textLayer.frame = sourceFrame.offsetBy(
                    dx: textOffset, dy: size.height - textOffset - sourceFrame.height)
                addSublayer(textLayer)
            }
        }
    }

    private static func newTextLayer(content: String) -> CATextLayer {
        let fontSize = NSFont.systemFontSize * 2
        let font = NSFont.systemFont(ofSize: fontSize)
        let textLayer = CATextLayer()
        textLayer.contentsScale = Polyhedron.scale
        let stringSize = content.size(withAttributes: [.font: font])
        textLayer.frame = CGRect(origin: .zero,
                                 size: stringSize)
        textLayer.font = font
        textLayer.fontSize = fontSize
        textLayer.alignmentMode = .left
        textLayer.string = content
        textLayer.backgroundColor = CGColor.clear
        textLayer.foregroundColor = CGColor.init(gray: 1.0, alpha: 0.3)
        textLayer.rasterizationScale = Polyhedron.scale
        textLayer.shouldRasterize = true
        textLayer.isOpaque = true
        return textLayer
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animateOneFrame() {
        // update object position
        let rotation = self.rotation
        let rendering = cachedRenderings[rotation]
        let boundingBox = rendering.boundingBox
        var positionX = self.positionX
        var velocityX = self.velocityX
        let newPositionX = positionX + velocityX
        let left = newPositionX + boundingBox.left
        let right = newPositionX - boundingBox.right
        if left < 0 || right > maxX {
            velocityX = -velocityX
            self.velocityX = velocityX
        }
        positionX += velocityX
        self.positionX = positionX
        var positionY = self.positionY
        var velocityY = self.velocityY
        let newPositionY = positionY + velocityY
        let bottom = newPositionY + boundingBox.bottom
        let top = newPositionY - boundingBox.top
        if bottom < 0 || top > maxY {
            velocityY = -velocityY
            self.velocityY = velocityY
        }
        positionY += velocityY
        self.positionY = positionY
        let frameNumber = (self.frameNumber + 1) % framesPerDegree
        if frameNumber == 0 {
            self.rotation = (rotation + 1) % PolyhedraFullLayer.degrees
        }
        self.frameNumber = frameNumber
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        polyhedraLayer.sublayers = rendering.layer
        polyhedraLayer.frame.origin.x = CGFloat(positionX)
        polyhedraLayer.frame.origin.y = CGFloat(positionY)
        CATransaction.commit()
    }

}
