import Cocoa
import simd

// this is used in a set of edges to classify whether it is visible
struct Edge: Hashable {
    let startPointIdx: Int
    let endPointIdx: Int

    init(idx0: Int, idx1: Int) {
        // always put the smaller index first, so (1,2) and (2,1) will both hash to the same value
        if idx0 < idx1 {
            startPointIdx = idx0
            endPointIdx = idx1
        } else {
            startPointIdx = idx1
            endPointIdx = idx0
        }
    }
}

struct CachedRendering {
    let points: [CGPoint]
    let edges: [Edge: Bool]
    let frontColor: NSColor
    let backColor: NSColor

    func render(position: CGPoint, radius: CGFloat, lineWidth: CGFloat) {
        let mappedPoints = points.map { CGPoint(
            x: CGFloat(position.x + radius + radius * $0.x),
            y: CGFloat(position.y + radius - radius * -$0.y)
        ) }
        // draw edges
        let frontPath = NSBezierPath()
        let backPath = NSBezierPath()
        for (edge, visible) in edges {
            let startPoint = mappedPoints[edge.startPointIdx]
            let endPoint = mappedPoints[edge.endPointIdx]
            let path = visible ? frontPath : backPath
            path.move(to: startPoint)
            path.line(to: endPoint)
        }
        backColor.set()
        backPath.lineWidth = lineWidth
        backPath.stroke()
        frontColor.set()
        frontPath.lineWidth = lineWidth
        frontPath.stroke()
    }
}

struct Polyhedron: Codable {
    let name: String
    let vertices: [[Float]]
    let faces: [[Int]]

    private static let camera = vector_float3(0, 0, 1)

    func generateCachedRendering(degrees: Int, color: NSColor) -> CachedRendering {
        // do a transformation
        let transformation = Polyhedron.transform(radians: Float(degrees) * Float.pi / 180.0)
        let transformedVertices = vertices.map { transformation * vector_float3(x: $0[0], y: $0[1], z: $0[2]) }
        let points = transformedVertices.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
        // do back-face culling
        var allEdges = Set<Edge>()
        var visibleEdges = Set<Edge>()
        for face in faces {
            let point0 = transformedVertices[face[0]]
            let point1 = transformedVertices[face[1]]
            let point2 = transformedVertices[face[2]]
            let edge0 = point1 - point0
            let edge1 = point2 - point1
            let normal = simd_normalize(simd_cross(edge0, edge1))
            let dot = simd_dot(normal, Polyhedron.camera)
            let angle = acosf(dot / (simd_length(normal) * simd_length(Polyhedron.camera)))
            var edges = [Edge]()
            // the face is visible, so make sure we draw the edges
            edges.append(Edge(idx0: face.first!, idx1: face.last!))
            for (vertexIdx, idx1) in face.dropLast().enumerated() {
                let idx0 = face[vertexIdx + 1]
                edges.append(Edge(idx0: idx0, idx1: idx1))
            }
            for edge in edges {
                allEdges.insert(edge)
                if angle <= Float.pi / 2 {
                    // the face's normal is facing towards from the camera
                    visibleEdges.insert(edge)
                }
            }
        }
        var edges = [Edge: Bool]()
        for edge in allEdges {
            edges[edge] = visibleEdges.contains(edge)
        }
        let backColor = color.withAlphaComponent(0.25)
        return CachedRendering(points: points, edges: edges, frontColor: color, backColor: backColor)
    }

    func generateCachedRenderings(color: NSColor?) -> [CachedRendering] {
        var renderedPolygons = [CachedRendering]()
        // precompute all of the rotations
        for degrees in 0 ..< 360 {
            let effectiveColor = color ?? PolyhedraRegistry.colors[degrees]
            let cachedRendering = generateCachedRendering(degrees: degrees, color: effectiveColor)
            renderedPolygons.append(cachedRendering)
        }
        return renderedPolygons
    }

    private static func rotate(radians: Float, axis: String) -> matrix_float3x3 {
        let cosine = cosf(radians)
        let sine = sinf(radians)
        var transform = matrix_identity_float3x3
        if axis == "x" {
            transform[1, 1] = cosine
            transform[2, 2] = cosine
            transform[2, 1] = sine
            transform[1, 2] = -sine
        } else if axis == "y" {
            transform[0, 0] = cosine
            transform[2, 2] = cosine
            transform[0, 2] = sine
            transform[2, 0] = -sine
        } else if axis == "z" {
            transform[0, 0] = cosine
            transform[1, 1] = cosine
            transform[1, 0] = sine
            transform[0, 1] = -sine
        }
        return transform
    }

    private static func transform(radians: Float) -> matrix_float3x3 {
        return
            rotate(radians: Float.pi / 4, axis: "z") *
            rotate(radians: Float.pi / 4, axis: "y") *
            rotate(radians: radians, axis: "x")
    }
}

class PolyhedraRegistry {
    static let all: [Polyhedron] = loadPolyhedra()
    static let colors: [NSColor] = loadColors()
    static let randomWithoutName = "Random (without name)"
    static let randomWithName = "Random"
    static let defaultName = randomWithName

    private static func loadPolyhedra() -> [Polyhedron] {
        let bundle = Bundle(for: PolyhedraRegistry.self)
        let decoder = JSONDecoder()
        guard
            let url = bundle.url(forResource: "polyhedra.json", withExtension: nil),
            let data = try? Data(contentsOf: url),
            let loaded = try? decoder.decode([Polyhedron].self, from: data)
        else {
            fatalError("Failed to decode polyhedra from bundle.")
        }
        return loaded
    }

    private static func loadColors() -> [NSColor] {
        let bundle = Bundle(for: PolyhedraRegistry.self)
        let decoder = JSONDecoder()
        guard
            let url = bundle.url(forResource: "colors.json", withExtension: nil),
            let data = try? Data(contentsOf: url),
            let loaded = try? decoder.decode([String].self, from: data)
        else {
            fatalError("Failed to decode polyhedra from bundle.")
        }
        return loaded.map { (hexString) -> NSColor in
            var hex: UInt64 = 0
            Scanner(string: hexString).scanHexInt64(&hex)
            return NSColor(
                red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((hex & 0xFF00) >> 8) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: 1.0
            )
        }
    }

    static func forName(_ name: String) -> Polyhedron {
        if name == randomWithoutName || name == randomWithName {
            return all.randomElement()!
        }
        for polyhedron in all where polyhedron.name == name {
            return polyhedron
        }
        for polyhedron in all where polyhedron.name == defaultName {
            return polyhedron
        }
        return all[0]
    }

    static func generateRows() -> [PolyhedronCellInfo] {
        var polyhedraRows: [PolyhedronCellInfo] = []
        polyhedraRows.append(PolyhedronCellInfo(name: PolyhedraRegistry.randomWithName, cachedRendering: nil))
        polyhedraRows.append(PolyhedronCellInfo(name: PolyhedraRegistry.randomWithoutName, cachedRendering: nil))
        for polyhedron in PolyhedraRegistry.all.sorted(by: { (polyhedron0, polyhedron1) -> Bool in
            polyhedron0.name < polyhedron1.name
        }) {
            let cachedRendering = polyhedron.generateCachedRendering(degrees: 60, color: .textColor)
            polyhedraRows.append(PolyhedronCellInfo(name: polyhedron.name, cachedRendering: cachedRendering))
        }
        return polyhedraRows
    }
}

struct PolyhedronCellInfo {
    let name: String
    let cachedRendering: CachedRendering?
}
