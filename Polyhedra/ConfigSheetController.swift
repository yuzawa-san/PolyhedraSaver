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

    private let settings = PolyhedraSettings()
    private let rows: [PolyhedronCellInfo] = PolyhedraRegistry.generateRows()
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
            cellView.cachedRendering = polyhedraRow.cachedRendering
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
        return 48
    }
}

class PolyhedronCellView: NSTableCellView {
    var cachedRendering: CachedRendering?
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.clear.setFill()
        bounds.fill()
        if cachedRendering == nil {
            return
        }
        let origin = CGPoint(x: frame.width * 0.05, y: frame.width * 0.05)
        cachedRendering!.render(position: origin, radius: frame.width * 0.45, lineWidth: 0.5)
    }
}
