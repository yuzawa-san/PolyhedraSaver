import Cocoa
import simd

// this is used in a set of edges which need to be rendered
struct VisibleEdge: Hashable {
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
    let edges: [VisibleEdge]
    let color: NSColor

    func render(position: CGPoint, radius: CGFloat) -> NSBezierPath {
        let mappedPoints = points.map { CGPoint(
            x: CGFloat(position.x + radius + radius * $0.x),
            y: CGFloat(position.y + radius - radius * -$0.y)
        ) }
        // draw edges
        let path = NSBezierPath()
        for edge in edges {
            let startPoint = mappedPoints[edge.startPointIdx]
            let endPoint = mappedPoints[edge.endPointIdx]
            path.move(to: startPoint)
            path.line(to: endPoint)
        }
        return path
    }
}

struct Polyhedron: Codable {
    let name: String
    let vertices: [[Float]]
    let faces: [[Int]]

    private static let camera = vector_float3(0, 0, 1)

    func generateCachedRendering(_ degrees: Int) -> CachedRendering {
        // do a transformation
        let transformation = Polyhedron.transform(radians: Float(degrees) * Float.pi / 180.0)
        let transformedVertices = vertices.map { transformation * vector_float3(x: $0[0], y: $0[1], z: $0[2]) }
        let points = transformedVertices.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
        // do back-face culling
        var edges = Set<VisibleEdge>()
        for face in faces {
            let point0 = transformedVertices[face[0]]
            let point1 = transformedVertices[face[1]]
            let point2 = transformedVertices[face[2]]
            let edge0 = point1 - point0
            let edge1 = point2 - point1
            let normal = simd_normalize(simd_cross(edge0, edge1))
            let dot = simd_dot(normal, Polyhedron.camera)
            let angle = acosf(dot / (simd_length(normal) * simd_length(Polyhedron.camera)))
            if angle > Float.pi / 2 {
                // the face's normal is facing away from the camera
                continue
            }
            // the face is visible, so make sure we draw the edges
            edges.insert(VisibleEdge(idx0: face.first!, idx1: face.last!))
            for (vertexIdx, idx1) in face.dropLast().enumerated() {
                let idx0 = face[vertexIdx + 1]
                edges.insert(VisibleEdge(idx0: idx0, idx1: idx1))
            }
        }
        // simple interpolation on hue from degrees
        let hue = CGFloat(degrees) / 360.0
        let color = NSColor(calibratedHue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        return CachedRendering(points: points, edges: Array(edges), color: color)
    }

    func generateCachedRenderings() -> [CachedRendering] {
        var renderedPolygons = [CachedRendering]()
        // precompute all of the rotations
        for degrees in 0 ..< 360 {
            renderedPolygons.append(generateCachedRendering(degrees))
        }
        return renderedPolygons
    }

    private static let initialTransform = createInitialTransform()

    // reflect and rotate 45 degrees in X and Y axis
    // this is purely subjective to give a nice view of the objects.
    static func createInitialTransform() -> matrix_float3x3 {
        let value = sqrtf(2) / 2.0
        var reflect = matrix_identity_float3x3
        reflect[1, 1] = -1
        var transformX = matrix_identity_float3x3
        transformX[1, 1] = value
        transformX[1, 2] = value
        transformX[2, 1] = -value
        transformX[2, 2] = value
        var transformY = matrix_identity_float3x3
        transformY[0, 0] = value
        transformY[2, 0] = value
        transformY[0, 2] = -value
        transformY[2, 2] = value
        return transformX * reflect * transformY
    }

    // rotate in the Z axis
    static func transform(radians: Float) -> matrix_float3x3 {
        let cosine = cosf(radians)
        let sine = sinf(radians)
        var transformZ = matrix_identity_float3x3
        transformZ[0, 0] = cosine
        transformZ[1, 1] = cosine
        transformZ[0, 1] = sine
        transformZ[1, 0] = -sine
        return initialTransform * transformZ
    }
}

class PolyhedraRegistry {
    static let all: [Polyhedron] = loadPolyhedra()
    static let randomName = "Random"
    static let defaultName = "R05: Icosahedron"

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

    static func forName(_ name: String) -> Polyhedron {
        if name == randomName {
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
}
