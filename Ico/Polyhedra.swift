import Cocoa

class Polyhedra {
    static let all: [Polyhedron] = loadPolyhedra()
    static let randomName = "Random"
    static let defaultName = "R05: Icosahedron"

    private static func loadPolyhedra() -> [Polyhedron] {
        let bundle = Bundle(for: Polyhedra.self)
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

    static func forName(name: String) -> Polyhedron {
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
