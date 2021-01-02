import Cocoa

class ConfigSheetController: NSObject {
    @IBOutlet var window: NSWindow?
    @IBOutlet var polyhedronSelection: NSPopUpButton?
    @IBOutlet var singleColorCheckbox: NSButton?
    @IBOutlet var singleColorWell: NSColorWell?

    private let defaultsManager = DefaultsManager()
    private let projectUrl = "https://github.com/yuzawa-san/ico-saver"

    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigSheetController.self)
        myBundle.loadNibNamed("ConfigSheet", owner: self, topLevelObjects: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        polyhedronSelection!.addItem(withTitle: Polyhedron.randomName)
        for polyhedron in POLYHEDRA.sorted(by: { (polyhedron0, polyhedron1) -> Bool in
            return polyhedron0.name < polyhedron1.name
        }) {
            polyhedronSelection!.addItem(withTitle: polyhedron.name)
        }
        polyhedronSelection!.selectItem(withTitle: defaultsManager.polyhedronName)
        singleColorCheckbox!.state = defaultsManager.useColorOverride ? .on : .off
        singleColorWell!.color = defaultsManager.colorOverride
    }

    private func dismiss() {
        NSColorPanel.shared.close()
        window?.sheetParent?.endSheet(window!)
    }

    @IBAction func ok(_ sender: AnyObject) {
        defaultsManager.polyhedronName = polyhedronSelection!.titleOfSelectedItem!
        defaultsManager.useColorOverride = singleColorCheckbox!.state == .on
        defaultsManager.colorOverride = singleColorWell!.color
        defaultsManager.synchronize()
        dismiss()
    }

    @IBAction func cancel(_ sender: AnyObject) {
        dismiss()
    }

    @IBAction func info(_ sender: AnyObject) {
        if let url = URL(string: projectUrl) {
            NSWorkspace.shared.open(url)
        }
    }
}
