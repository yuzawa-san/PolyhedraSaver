import Cocoa
import simd

let POLYHEDRA = [
    Polyhedron(id: "ico", name: "icosahedron",vertices: [
        [0.00000000,  0.00000000, -0.95105650],
        [0.00000000,  0.85065080, -0.42532537],
        [0.80901698,  0.26286556, -0.42532537],
        [0.50000000, -0.68819095, -0.42532537],
        [-0.50000000, -0.68819095, -0.42532537],
        [-0.80901698,  0.26286556, -0.42532537],
        [0.50000000,  0.68819095,  0.42532537],
        [0.80901698, -0.26286556,  0.42532537],
        [0.00000000, -0.85065080,  0.42532537],
        [-0.80901698, -0.26286556,  0.42532537],
        [-0.50000000,  0.68819095,  0.42532537],
        [0.00000000,  0.00000000,  0.95105650],
    ], faces: [[    0,  2,  1],
               [    0,  3,  2],
               [    0,  4,  3],
               [    0,  5,  4],
               [    0,  1,  5],
               [    1,  6, 10],
               [    1,  2,  6],
               [    2,  7,  6],
               [    2,  3,  7],
               [    3,  8,  7],
               [    3,  4,  8],
               [    4,  9,  8],
               [    4,  5,  9],
               [    5, 10,  9],
               [    5,  1, 10],
               [    10,  6, 11],
               [    6,  7, 11],
               [    7,  8, 11],
               [    8,  9, 11],
               [    9, 10, 11]]),
    Polyhedron(id: "cube", name: "cube",vertices: [
        [ 0.577,  0.577,  0.577],
        [ 0.577,  0.577, -0.577],
        [ 0.577, -0.577, -0.577],
        [ 0.577, -0.577,  0.577],
        [-0.577,  0.577,  0.577],
        [-0.577,  0.577, -0.577],
        [-0.577, -0.577, -0.577],
        [-0.577, -0.577,  0.577]
    ], faces: [
        [0, 1, 2, 3],
        [7, 6, 5, 4],
        [1, 0, 4, 5],
        [3, 2, 6, 7],
        [2, 1, 5, 6],
        [0, 3, 7, 4]
    ])
]

struct RenderedEdge: Hashable {
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
struct RenderedPolyhedron {
    let points: Array<CGPoint>
    let edges: Array<RenderedEdge>
    let color: NSColor
}

struct Polyhedron {
    let id: String
    let name: String
    let vertices: Array<Array<Float>>
    let faces: Array<Array<Int>>
    
    func prerender() -> Array<RenderedPolyhedron> {
        var renderedPolygons = [RenderedPolyhedron]()
        let camera = vector_float3(0,0,1)
        for degrees in (0...359) {
            let transformation = Polyhedron.rotation_matrix(radians:Float(degrees) * 3.1416 / 180.0)
            let transformedVertices = vertices.map { transformation*vector_float3(x:$0[0], y:$0[1], z:$0[2]) }
            let points = transformedVertices.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
            var edges = Set<RenderedEdge>()
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
                edges.insert(RenderedEdge(a: face.first!, b: face.last!))
                for (i, b) in face.dropLast().enumerated() {
                    let a = face[i+1]
                    edges.insert(RenderedEdge(a: a, b: b))
                }
            }
            let hue = CGFloat(degrees) / 360.0
            let color = NSColor(calibratedHue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            renderedPolygons.append(RenderedPolyhedron(points: points, edges: Array(edges), color: color))
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
