import AppKit

class PolyhedronView: NSView {
    private var radius: CGFloat = .zero
    private var rotation: Int = .zero
    private var cachedRenderings: [CachedRendering] = []

    public init(origin: NSPoint, radius: CGFloat, cachedRenderings: [CachedRendering]) {
        super.init(frame: NSRect(origin: origin, size: NSSize(width: 2 * radius, height: 2 * radius)))
        self.radius = radius
        self.cachedRenderings = cachedRenderings
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func rotate() {
        rotation = (rotation + 1) % cachedRenderings.count
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        cachedRenderings[rotation].render(position: .zero, radius: radius, lineWidth: 1)
    }
}
