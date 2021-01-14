import ScreenSaver

class PolyhedraSettings {
    private var defaults: UserDefaults
    var polyhedron: Polyhedron
    var showPolyhedronName: Bool
    var fixedColor: NSColor?

    init() {
        let identifier = Bundle(for: PolyhedraSettings.self).bundleIdentifier
        defaults = ScreenSaverDefaults(forModuleWithName: identifier!)!
        let polyhedronName = defaults.string(forKey: "polyhedron_name") ?? PolyhedraRegistry.defaultName
        polyhedron = PolyhedraRegistry.forName(polyhedronName)
        showPolyhedronName = defaults.bool(forKey: "show_polyhedron_name")
        fixedColor = PolyhedraSettings.readColorOverride(defaults)
    }

    private static func readColorOverride(_ defaults: UserDefaults) -> NSColor? {
        guard
            let storedData = defaults.data(forKey: "fixed_color"),
            let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: storedData),
            let color = unarchivedData as NSColor?
        else {
            return nil
        }

        return color
    }

    func setPolyhedron(name: String) {
        polyhedron = PolyhedraRegistry.forName(name)
    }

    func write() {
        defaults.setValue(polyhedron.name, forKey: "polyhedron_name")
        defaults.setValue(showPolyhedronName, forKey: "show_polyhedron_name")
        if fixedColor == nil {
            defaults.removeObject(forKey: "fixed_color")
        } else {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: fixedColor!, requiringSecureCoding: false) {
                defaults.set(data, forKey: "fixed_color")
            }
        }
        defaults.synchronize()
    }
}
