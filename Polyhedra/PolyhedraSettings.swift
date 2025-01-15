import ScreenSaver

class PolyhedraSettings {
    private var defaults: UserDefaults
    private var polyhedronName: String = ""
    private var polyhedron: Polyhedron?
    private var showPolyhedronName: Bool = false
    var showMessage: Bool = false
    var message: String?
    var fixedColor: NSColor?

    init() {
        let identifier = Bundle(for: PolyhedraSettings.self).bundleIdentifier
        defaults = ScreenSaverDefaults(forModuleWithName: identifier!)!
        showMessage = defaults.bool(forKey: "show_message")
        message = defaults.string(forKey: "message")
        fixedColor = PolyhedraSettings.readColorOverride(defaults)
        let name = defaults.string(forKey: "polyhedron_name") ?? PolyhedraRegistry.defaultName
        setPolyhedronName(name: name)
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

    func setPolyhedronName(name: String) {
        polyhedronName = name
        showPolyhedronName = name == PolyhedraRegistry.randomWithName
        polyhedron = PolyhedraRegistry.forName(name)
    }

    func getPolyhedron() -> Polyhedron {
        return polyhedron!
    }

    func getPolyhedronName() -> String {
        return polyhedronName
    }

    func getMessage() -> String {
        return message ?? Host.current().localizedName ?? ""
    }

    func shouldShowPolyhedronName() -> Bool {
        return showPolyhedronName
    }

    func write() {
        defaults.setValue(polyhedronName, forKey: "polyhedron_name")
        if fixedColor == nil {
            defaults.removeObject(forKey: "fixed_color")
        } else {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: fixedColor!, requiringSecureCoding: false) {
                defaults.set(data, forKey: "fixed_color")
            }
        }
        defaults.set(showMessage, forKey: "show_message")
        defaults.set(message, forKey: "message")
        defaults.synchronize()
    }
}
