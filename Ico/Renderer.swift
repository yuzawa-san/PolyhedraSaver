import Cocoa
import simd

struct VisibleEdge: Hashable {
    let startPointIdx: Int
    let endPointIdx: Int

    init(idx0: Int, idx1: Int) {
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
}

struct Polyhedron {
    let name: String
    let vertices: [Array[Float]>
    let faces: [Array[Int]>

    func generateCachedRenderings() -> [CachedRendering] {
        var renderedPolygons = [CachedRendering]()
        let camera = vector_float3(0, 0, 1)
        for degrees in (0...359) {
            let transformation = Polyhedron.rotation_matrix(radians: Float(degrees) * 3.1416 / 180.0)
            let transformedVertices = vertices.map { transformation*vector_float3(x: $0[0], y: $0[1], z: $0[2]) }
            let points = transformedVertices.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
            var edges = Set<VisibleEdge>()
            for face in faces {
                let point0 = transformedVertices[face[0]]
                let point1 = transformedVertices[face[1]]
                let point2 = transformedVertices[face[2]]
                let edge0 = point1 - point0
                let edge1 = point2 - point1
                let normal = simd_normalize(simd_cross(edge0, edge1))
                let angle = acosf(simd_dot(normal, camera) / (simd_length(normal) * simd_length(camera)))
                if angle > Float.pi / 2 {
                    // the face's normal is facing away from the camera
                    continue
                }
                edges.insert(VisibleEdge(idx0: face.first!, idx1: face.last!))
                for (vertexIdx, idx1) in face.dropLast().enumerated() {
                    let idx0 = face[vertexIdx+1]
                    edges.insert(VisibleEdge(idx0: idx0, idx1: idx1))
                }
            }
            let hue = CGFloat(degrees) / 360.0
            let color = NSColor(calibratedHue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            renderedPolygons.append(CachedRendering(points: points, edges: Array(edges), color: color))
        }
        return renderedPolygons
    }

    static func rotation_matrix(radians: Float) -> matrix_float3x3 {
        let cosine = cosf(radians)
        let sine = sinf(radians)
        var mx = matrix_identity_float3x3
        mx[1, 1] = cosine
        mx[1, 2] = sine
        mx[2, 1] = -sine
        mx[2, 2] = cosine
        var my = matrix_identity_float3x3
        my[0, 0] = cosine
        my[2, 0] = sine
        my[0, 2] = -sine
        my[2, 2] = cosine
        return matrix_multiply(mx, my)
    }

    static func forName(name: String) -> Polyhedron {
        if name == "Random" {
            return POLYHEDRA.randomElement()!
        }
        for polyhedron in POLYHEDRA where polyhedron.name == name {
            return polyhedron
        }
        return POLYHEDRA[0]
    }
}
