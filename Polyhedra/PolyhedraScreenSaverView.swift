import ScreenSaver
import Foundation
import IOKit.ps

class PolyhedraScreenSaverView: ScreenSaverView {
    private lazy var sheetController = ConfigSheetController()
    private var polyhedronScreenSaverLayer: PolyhedraFullLayer?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        wantsLayer = true
    }

    // if we're on battery let's lower the FPS
    static func calculateFramesPerSecond() -> Int {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for source in sources {
            if let info = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: AnyObject],
                let state = info[kIOPSPowerSourceStateKey] as? String {
                if state == kIOPSBatteryPowerValue {
                    return PolyhedraFullLayer.fpsSlow
                }
            }
        }
        return PolyhedraFullLayer.fpsFast
    }

    override func startAnimation() {
        let fps = PolyhedraScreenSaverView.calculateFramesPerSecond()
        animationTimeInterval = 1.0 / Double(fps)
        let polyhedronScreenSaverLayer = PolyhedraFullLayer(size: frame.size, fps: fps, isPreview: isPreview)
        layer?.drawsAsynchronously = true
        layer?.isOpaque = true
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
