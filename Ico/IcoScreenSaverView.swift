import ScreenSaver

class IcoScreenSaverView: ScreenSaverView {

    private var position: CGPoint = .zero
    private var velocity: CGVector = .zero
    private var radius: CGFloat = .zero
    private var maxX: CGFloat = .zero
    private var maxY: CGFloat = .zero

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        radius = isPreview ? 25 : 150
        maxX = frame.width - 2 * radius
        maxY = frame.height - 2 * radius
        position.x = CGFloat.random(in: 0..<maxX)
        position.y = CGFloat.random(in: 0..<maxY)
        velocity.dx = 10
        velocity.dy = 10
        animationTimeInterval = 1.0 / 20
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: NSRect) {
        let background = NSBezierPath(rect: bounds)
        NSColor.black.setFill()
        background.fill()
        
        let paddleRect = NSRect(x: position.x, y: position.y, width: radius*2, height: radius*2)
        let paddle = NSBezierPath(rect: paddleRect)
        NSColor.red.setFill()
        paddle.fill()
        
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
        
        needsDisplay = true
    }

}
