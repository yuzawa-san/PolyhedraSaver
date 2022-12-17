import AppKit

class PolyhedraLayer: CALayer {
    private let backLayer: CAShapeLayer
    private let frontLayer: CAShapeLayer

    public init(lineWidth: CGFloat) {
        let scale = NSScreen.main!.backingScaleFactor
        let backLayer = CAShapeLayer()
        backLayer.contentsScale = scale
        backLayer.lineWidth = lineWidth
        backLayer.isOpaque = true
        self.backLayer = backLayer
        let frontLayer = CAShapeLayer()
        frontLayer.contentsScale = scale
        frontLayer.lineWidth = lineWidth
        frontLayer.isOpaque = true
        self.frontLayer = frontLayer
        super.init()
        isOpaque = true
        addSublayer(backLayer)
        addSublayer(frontLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setRendering(position: CGPoint, rendering: CachedRendering?) {
        if let rendering = rendering {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            frontLayer.path = rendering.frontPath
            frontLayer.strokeColor = rendering.frontColor
            backLayer.path = rendering.backPath
            backLayer.strokeColor = rendering.backColor
            frame.origin = position
            CATransaction.commit()
        }
    }

}
