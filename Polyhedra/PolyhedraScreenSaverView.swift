import ScreenSaver

class PolyhedraScreenSaverView: ScreenSaverView {
    private lazy var sheetController = ConfigSheetController()
    private var polyhedronScreenSaverLayer: PolyhedraFullLayer?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 25
        wantsLayer = true
    }

    override func startAnimation() {
        let polyhedronScreenSaverLayer = PolyhedraFullLayer(size: frame.size, isPreview: isPreview)
        layer?.addSublayer(polyhedronScreenSaverLayer)
        self.polyhedronScreenSaverLayer = polyhedronScreenSaverLayer
        super.startAnimation()
    }

    override func stopAnimation() {
        polyhedronScreenSaverLayer = nil
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
        polyhedronScreenSaverLayer?.animateOneFrame()
    }
}
