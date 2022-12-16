import Cocoa

class ConfigSheetController: NSObject {
    @IBOutlet var window: NSWindow!
    @IBOutlet var polyhedronSettingsController: PolyhedraSettingsController!

    private let projectUrl = "https://github.com/yuzawa-san/PolyhedraSaver"
    private let currentBundle = Bundle(for: ConfigSheetController.self)

    override init() {
        super.init()
        currentBundle.loadNibNamed("ConfigSheet", owner: self, topLevelObjects: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        polyhedronSettingsController.load()
    }

    private func dismiss() {
        NSColorPanel.shared.close()
        window?.sheetParent?.endSheet(window!)
    }

    @IBAction func ok(_: AnyObject) {
        polyhedronSettingsController.save()
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

class PolyhedraSettingsController: NSObject {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var fixedColorCheckbox: NSButton!
    @IBOutlet var fixedColorWell: NSColorWell!
    @IBOutlet var informationLabel: NSTextField!

    private static let radius: CGFloat = 24
    private let settings = PolyhedraSettings()
    private let rows: [PolyhedronCellInfo] = PolyhedraRegistry.generateRows(radius: radius)
    private let currentBundle = Bundle(for: PolyhedraSettingsController.self)

    override init() {
        super.init()
    }

    func load() {
        var selectedIdx = 0
        for (idx, info) in rows.enumerated() where info.name == settings.getPolyhedronName() {
            selectedIdx = idx
        }
        var indices = IndexSet()
        indices.insert(selectedIdx)
        tableView.selectRowIndexes(indices, byExtendingSelection: false)
        tableView.scrollRowToVisible(selectedIdx)
        fixedColorCheckbox.state = settings.fixedColor == nil ? .off : .on
        fixedColorWell.color = settings.fixedColor ?? NSColor.red
        if let text = currentBundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            informationLabel.stringValue =
                "PolyhedraSaver by yuzawa-san\n" +
                "Version " + text + "\n" +
                "Please star on GitHub for Homebrew updates\n" +
                "See README for polyhedra attribution information"
        }
    }

    func save() {
        settings.setPolyhedronName(name: rows[tableView.selectedRow].name)
        if fixedColorCheckbox.state == .on {
            settings.fixedColor = fixedColorWell.color
        } else {
            settings.fixedColor = nil
        }
        settings.write()
    }
}

extension PolyhedraSettingsController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in _: NSTableView) -> Int {
        return rows.count
    }

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        let polyhedraRow = rows[row]
        let key = tableColumn!.identifier.rawValue
        if key == "preview" {
            guard let cellView = tableView.makeView(withIdentifier:
                tableColumn!.identifier,
                owner: self) as? PolyhedronCellView
            else {
                return nil
            }
            cellView.wantsLayer = true
            cellView.layer?.sublayers?.removeAll()
            let polyhedronLayer = PolyhedraLayer(lineWidth: 0.5)
            polyhedronLayer.setRendering(position: .zero, rendering: polyhedraRow.cachedRendering)
            cellView.layer?.addSublayer(polyhedronLayer)
            return cellView
        } else {
            guard let cellView = tableView.makeView(withIdentifier:
                tableColumn!.identifier,
                owner: self) as? NSTableCellView
            else {
                return nil
            }
            cellView.textField?.stringValue = polyhedraRow.name
            return cellView
        }
    }

    func tableView(_: NSTableView, heightOfRow _: Int) -> CGFloat {
        return PolyhedraSettingsController.radius * 2
    }
}

class PolyhedronCellView: NSTableCellView {
}
