import ScreenSaver

class DefaultsManager {
    private var defaults: UserDefaults

    init() {
        let identifier = Bundle(for: DefaultsManager.self).bundleIdentifier
        defaults = ScreenSaverDefaults(forModuleWithName: identifier!)!
    }

    func synchronize() {
        defaults.synchronize()
    }

    var polyhedronName: String {
        get {
            return defaults.string(forKey: "polyhedron_name") ?? PolyhedraRegistry.defaultName
        }
        set(value) {
            defaults.setValue(value, forKey: "polyhedron_name")
        }
    }

    var useColorOverride: Bool {
        get {
            return defaults.bool(forKey: "use_color_override")
        }
        set(value) {
            defaults.setValue(value, forKey: "use_color_override")
        }
    }

    var colorOverride: NSColor {
        get {
            guard
                let storedData = defaults.data(forKey: "color_override"),
                let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: storedData),
                let color = unarchivedData as NSColor?
            else {
                return NSColor.red
            }
            return color
        }
        set(color) {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
                defaults.set(data, forKey: "color_override")
            }
        }
    }
}
