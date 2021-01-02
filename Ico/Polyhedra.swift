let POLYHEDRA = [
    Polyhedron(name: "icosahedron", vertices: [
        [0.00000000, 0.00000000, -0.95105650],
        [0.00000000, 0.85065080, -0.42532537],
        [0.80901698, 0.26286556, -0.42532537],
        [0.50000000, -0.68819095, -0.42532537],
        [-0.50000000, -0.68819095, -0.42532537],
        [-0.80901698, 0.26286556, -0.42532537],
        [0.50000000, 0.68819095, 0.42532537],
        [0.80901698, -0.26286556, 0.42532537],
        [0.00000000, -0.85065080, 0.42532537],
        [-0.80901698, -0.26286556, 0.42532537],
        [-0.50000000, 0.68819095, 0.42532537],
        [0.00000000, 0.00000000, 0.95105650]
    ], faces: [[    0, 2, 1],
               [    0, 3, 2],
               [    0, 4, 3],
               [    0, 5, 4],
               [    0, 1, 5],
               [    1, 6, 10],
               [    1, 2, 6],
               [    2, 7, 6],
               [    2, 3, 7],
               [    3, 8, 7],
               [    3, 4, 8],
               [    4, 9, 8],
               [    4, 5, 9],
               [    5, 10, 9],
               [    5, 1, 10],
               [    10, 6, 11],
               [    6, 7, 11],
               [    7, 8, 11],
               [    8, 9, 11],
               [    9, 10, 11]]),
    Polyhedron(name: "cube", vertices: [
        [ 0.577, 0.577, 0.577],
        [ 0.577, 0.577, -0.577],
        [ 0.577, -0.577, -0.577],
        [ 0.577, -0.577, 0.577],
        [-0.577, 0.577, 0.577],
        [-0.577, 0.577, -0.577],
        [-0.577, -0.577, -0.577],
        [-0.577, -0.577, 0.577]
    ], faces: [
        [0, 1, 2, 3],
        [7, 6, 5, 4],
        [1, 0, 4, 5],
        [3, 2, 6, 7],
        [2, 1, 5, 6],
        [0, 3, 7, 4]
    ]),
    Polyhedron(name: "x", vertices: [
            [-0.61237244, -0.35355339, 0.00000000],
    [0.61237244, -0.35355339, 0.00000000],
    [0.00000000, 0.00000000, -1.00000000],
    [0.00000000, 0.70710678, 0.00000000],
    [0.00000000, 0.00000000, 1.00000000]
        ], faces: [
            [0, 3, 2],
    [0, 2, 1],
    [0, 1, 4],
    [0, 4, 3],
    [1, 2, 3],
    [1, 3, 4]
        ])
]
