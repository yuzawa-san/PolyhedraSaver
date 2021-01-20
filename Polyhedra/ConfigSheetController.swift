import Cocoa

class ConfigSheetController: NSObject {
    @IBOutlet var window: NSWindow!
    @IBOutlet var showPolyhedronNameCheckbox: NSButton!
    @IBOutlet var colorOverrideCheckbox: NSButton!
    @IBOutlet var colorOverrideWell: NSColorWell!
    @IBOutlet var informationLabel: NSTextField!
    @IBOutlet var tableViewController: PolyhedronTableViewController!

    private let settings = PolyhedraSettings()
    private let projectUrl = "https://github.com/yuzawa-san/PolyhedraSaver"
    private let currentBundle = Bundle(for: ConfigSheetController.self)

    override init() {
        super.init()
        currentBundle.loadNibNamed("ConfigSheet", owner: self, topLevelObjects: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tableViewController.name = settings.polyhedron.name
        showPolyhedronNameCheckbox.state = settings.showPolyhedronName ? .on : .off
        colorOverrideCheckbox.state = settings.fixedColor == nil ? .off : .on
        colorOverrideWell.color = settings.fixedColor ?? NSColor.red
        if let text = currentBundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            informationLabel.stringValue = "Version " + text + " by yuzawa-san"
        }
    }

    private func dismiss() {
        NSColorPanel.shared.close()
        window?.sheetParent?.endSheet(window!)
    }

    @IBAction func ok(_: AnyObject) {
        // save settings
        settings.setPolyhedron(name: tableViewController.name)
        settings.showPolyhedronName = showPolyhedronNameCheckbox.state == .on
        if colorOverrideCheckbox.state == .on {
            settings.fixedColor = colorOverrideWell.color
        } else {
            settings.fixedColor = nil
        }
        settings.write()
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

class PolyhedronTableViewController: NSObject {
    private let polyhedraRows: [PolyhedronCellInfo] = PolyhedraRegistry.generateRows()

    @IBOutlet var tableView: NSTableView!

    override init() {
        super.init()
    }

    var name: String {
        get {
          return polyhedraRows[tableView.selectedRow].name
        }
        set (newName) {
            var selectedIdx = 0
            for (idx, info) in polyhedraRows.enumerated() where info.name == newName {
                selectedIdx = idx
            }
            var indices = IndexSet()
            indices.insert(selectedIdx)
            tableView.selectRowIndexes(indices, byExtendingSelection: false)
            tableView.scrollRowToVisible(selectedIdx)
        }
      }
}

extension PolyhedronTableViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in _: NSTableView) -> Int {
        return polyhedraRows.count
    }

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        let polyhedraRow = polyhedraRows[row]
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
        let path = cachedRendering!.render(position: origin, radius: frame.width * 0.45)
        NSColor.black.set()
        path.lineWidth = 0.5
        path.stroke()
    }
}
