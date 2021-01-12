import Cocoa

class ConfigSheetController: NSObject {
    @IBOutlet var window: NSWindow?
    @IBOutlet var polyhedronSelection: NSPopUpButton?
    @IBOutlet var showPolyhedronNameCheckbox: NSButton?
    @IBOutlet var colorOverrideCheckbox: NSButton?
    @IBOutlet var colorOverrideWell: NSColorWell?
    @IBOutlet var informationLabel: NSTextField?

    private let defaultsManager = DefaultsManager()
    private let projectUrl = "https://github.com/yuzawa-san/PolyhedraSaver"
    private let currentBundle = Bundle(for: ConfigSheetController.self)

    override init() {
        super.init()
        currentBundle.loadNibNamed("ConfigSheet", owner: self, topLevelObjects: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // fill up polyhedron menu
        polyhedronSelection!.addItem(withTitle: PolyhedraRegistry.randomName)
        for polyhedron in PolyhedraRegistry.all.sorted(by: { (polyhedron0, polyhedron1) -> Bool in
            polyhedron0.name < polyhedron1.name
        }) {
            polyhedronSelection!.addItem(withTitle: polyhedron.name)
        }
        // load settings into UI
        polyhedronSelection!.selectItem(withTitle: defaultsManager.polyhedronName)
        showPolyhedronNameCheckbox!.state = defaultsManager.showPolyhedronName ? .on : .off
        colorOverrideCheckbox!.state = defaultsManager.useColorOverride ? .on : .off
        colorOverrideWell!.color = defaultsManager.colorOverride
        if let text = currentBundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            informationLabel!.stringValue = "Version " + text + " by yuzawa-san"
        }
    }

    private func dismiss() {
        NSColorPanel.shared.close()
        window?.sheetParent?.endSheet(window!)
    }

    @IBAction func ok(_: AnyObject) {
        // save settings
        defaultsManager.polyhedronName = polyhedronSelection!.titleOfSelectedItem!
        defaultsManager.showPolyhedronName = showPolyhedronNameCheckbox!.state == .on
        defaultsManager.useColorOverride = colorOverrideCheckbox!.state == .on
        defaultsManager.colorOverride = colorOverrideWell!.color
        defaultsManager.synchronize()
        dismiss()
    }

    @IBAction func cancel(_: AnyObject) {
        dismiss()
    }

    @IBAction func info(_: AnyObject) {
        if let url = URL(string: projectUrl) {
            NSWorkspace.shared.open(url)
        }
    }
}
