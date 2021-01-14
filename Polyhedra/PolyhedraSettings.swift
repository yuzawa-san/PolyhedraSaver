import ScreenSaver

class PolyhedraSettings {
    private var defaults: UserDefaults
    var polyhedron: Polyhedron
    var useColorOverride: Bool
    var showPolyhedronName: Bool
    var colorOverride: NSColor

    init() {
        let identifier = Bundle(for: PolyhedraSettings.self).bundleIdentifier
        defaults = ScreenSaverDefaults(forModuleWithName: identifier!)!
        let polyhedronName = defaults.string(forKey: "polyhedron_name") ?? PolyhedraRegistry.defaultName
        polyhedron = PolyhedraRegistry.forName(polyhedronName)
        useColorOverride = defaults.bool(forKey: "use_color_override")
        showPolyhedronName = defaults.bool(forKey: "show_polyhedron_name")
        colorOverride = PolyhedraSettings.readColorOverride(defaults)
    }

    private static func readColorOverride(_ defaults: UserDefaults) -> NSColor {
        guard
            let storedData = defaults.data(forKey: "color_override"),
            let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: storedData),
            let colorOverride = unarchivedData as NSColor?
        else {
            return NSColor.red
        }
        return colorOverride
    }

    func setPolyhedron(name: String) {
        polyhedron = PolyhedraRegistry.forName(name)
    }

    func write() {
        defaults.setValue(polyhedron.name, forKey: "polyhedron_name")
        defaults.setValue(useColorOverride, forKey: "use_color_override")
        defaults.setValue(showPolyhedronName, forKey: "show_polyhedron_name")
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: colorOverride, requiringSecureCoding: false) {
            defaults.set(data, forKey: "color_override")
        }
        defaults.synchronize()
    }
}
