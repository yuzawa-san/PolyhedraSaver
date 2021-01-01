import ScreenSaver

class IcoScreenSaverView: ScreenSaverView {

    private var position: CGPoint = .zero
    private var velocity: CGVector = CGVector(dx: 5, dy: 5)
    private var radius: CGFloat = .zero
    private var maxX: CGFloat = .zero
    private var maxY: CGFloat = .zero
    private var rotation: Int = .zero
    private var renderedPolyhedron = [RenderedPolyhedron]()

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        radius = isPreview ? 25 : 150
        maxX = frame.width - 2 * radius
        maxY = frame.height - 2 * radius
        position.x = CGFloat.random(in: 0..<maxX)
        position.y = CGFloat.random(in: 0..<maxY)
        renderedPolyhedron = POLYHEDRA[0].prerender()
        animationTimeInterval = 1.0 / 30
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: NSRect) {
        // clear the screen
        NSColor.black.setFill()
        bounds.fill()
        // fetch a cached set of edges
        let renderedPolygon = renderedPolyhedron[rotation]
        let points = renderedPolygon.points.map { CGPoint(
            x:CGFloat(position.x + radius + radius * $0.x),
            y:CGFloat(position.y + radius - radius * $0.y)) }
        let path = NSBezierPath()
        for edge in renderedPolygon.edges {
            let startPoint = points[edge.startPointIdx]
            let endPoint = points[edge.endPointIdx]
            path.move(to: startPoint)
            path.line(to: endPoint)
        }
        renderedPolygon.color.set()
        path.lineWidth = 1
        path.stroke()
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        
        position.x += velocity.dx
        let positionX = position.x
        if(positionX < 0 || positionX > maxX) {
            velocity.dx *= -1
        }
        
        position.y += velocity.dy
        let positionY = position.y
        if(positionY < 0 || positionY > maxY) {
            velocity.dy *= -1
        }
        
        rotation = (rotation + 1) % renderedPolyhedron.count
        
        needsDisplay = true
    }

}
