import Cocoa
import simd

struct VisibleEdge: Hashable {
    let startPointIdx: Int
    let endPointIdx: Int
    
    init(a: Int, b: Int) {
        if (a < b) {
            startPointIdx = a
            endPointIdx = b
        } else {
            startPointIdx = b
            endPointIdx = a
        }
    }
}

struct CachedRendering {
    let points: Array<CGPoint>
    let edges: Array<VisibleEdge>
    let color: NSColor
}

struct Polyhedron {
    let id: String
    let name: String
    let vertices: Array<Array<Float>>
    let faces: Array<Array<Int>>
    
    func generateCachedRenderings() -> Array<CachedRendering> {
        var renderedPolygons = [CachedRendering]()
        let camera = vector_float3(0,0,1)
        for degrees in (0...359) {
            let transformation = Polyhedron.rotation_matrix(radians:Float(degrees) * 3.1416 / 180.0)
            let transformedVertices = vertices.map { transformation*vector_float3(x:$0[0], y:$0[1], z:$0[2]) }
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
                if (angle > Float.pi / 2) {
                    // the face's normal is facing away from the camera
                    continue
                }
                edges.insert(VisibleEdge(a: face.first!, b: face.last!))
                for (i, b) in face.dropLast().enumerated() {
                    let a = face[i+1]
                    edges.insert(VisibleEdge(a: a, b: b))
                }
            }
            let hue = CGFloat(degrees) / 360.0
            let color = NSColor(calibratedHue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            renderedPolygons.append(CachedRendering(points: points, edges: Array(edges), color: color))
        }
        return renderedPolygons
    }
    
    static func rotation_matrix(radians:Float) -> matrix_float3x3{
        let c = cosf(radians);
        let s = sinf(radians);
        var mx = matrix_identity_float3x3
        mx[1,1] = c
        mx[1,2] = s
        mx[2,1] = -s
        mx[2,2] = c
        var my = matrix_identity_float3x3
        my[0,0] = c
        my[2,0] = s
        my[0,2] = -s
        my[2,2] = c
        return matrix_multiply(mx, my)
    }
}
