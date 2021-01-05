import Cocoa

class ConfigSheetController: NSObject {
    @IBOutlet var window: NSWindow?
    @IBOutlet var polyhedronSelection: NSPopUpButton?
    @IBOutlet var colorOverrideCheckbox: NSButton?
    @IBOutlet var colorOverrideWell: NSColorWell?
    @IBOutlet var informationLabel: NSTextField?

    private let defaultsManager = DefaultsManager()
    private let projectUrl = "https://github.com/yuzawa-san/ico-saver"
    private let currentBundle = Bundle(for: ConfigSheetController.self)

    override init() {
        super.init()
        currentBundle.loadNibNamed("ConfigSheet", owner: self, topLevelObjects: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        polyhedronSelection!.addItem(withTitle: Polyhedra.randomName)
        for polyhedron in Polyhedra.all.sorted(by: { (polyhedron0, polyhedron1) -> Bool in
            polyhedron0.name < polyhedron1.name
        }) {
            polyhedronSelection!.addItem(withTitle: polyhedron.name)
        }
        polyhedronSelection!.selectItem(withTitle: defaultsManager.polyhedronName)
        colorOverrideCheckbox!.state = defaultsManager.useColorOverride ? .on : .off
        colorOverrideWell!.color = defaultsManager.colorOverride
        if let text = currentBundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            informationLabel!.stringValue = "Ico (Version " + text + ") by yuzawa-san"
        }
    }

    private func dismiss() {
        NSColorPanel.shared.close()
        window?.sheetParent?.endSheet(window!)
    }

    @IBAction func ok(_: AnyObject) {
        defaultsManager.polyhedronName = polyhedronSelection!.titleOfSelectedItem!
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
