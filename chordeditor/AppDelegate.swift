import Cocoa

extension Notification.Name {
    static let didChangeChordInsertMode = Notification.Name("didChangeChordInsertMode")
    static let didChangeChordFormatting = Notification.Name("didChangeChordFormatting")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var chordInsertModeMenuItem: NSMenuItem!
    @IBOutlet var chordFormattingMenuItem: NSMenuItem!
    public var chordInsertMode: Bool = false
    public var chordFormatting: Bool = false

    func applicationDidFinishLaunching(_: Notification) {
        // Insert code here to initialize your application

        chordInsertMode = false
        chordFormatting = true
        NotificationCenter.default.post(name: .didChangeChordInsertMode, object: nil, userInfo: ["value": chordInsertMode])
        NotificationCenter.default.post(name: .didChangeChordFormatting, object: nil, userInfo: ["value": chordFormatting])
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldOpenUntitledFile(_: NSApplication) -> Bool {
        let controller = NSDocumentController.shared
        let docs = controller.recentDocumentURLs
        if docs.count > 0 {
            controller.openDocument(withContentsOf: docs[0], display: true, completionHandler: {
                (_: NSDocument?, _: Bool, errors: Error?) -> Void in
                if errors != nil {
                    controller.newDocument(nil)
                }
            })

            return false
        } else {
            do {
                try controller.openUntitledDocumentAndDisplay(true)
                return false
            } catch {
                return true
            }
        }
    }

    @IBAction func toggleChordInsertMode(_: Any) {
        setChordInsertMode(!chordInsertMode)
    }

    public func setChordInsertMode(_ chordInsertModeFlag: Bool) {
        chordInsertMode = chordInsertModeFlag
        NotificationCenter.default.post(name: .didChangeChordInsertMode, object: nil, userInfo: ["value": chordInsertModeFlag])
        chordInsertModeMenuItem.title = chordInsertModeFlag ? "Disable Chord Insert Mode" : "Enable Chord Insert Mode"
    }

    @IBAction func toggleChordFormatting(_: Any) {
        setChordFormatting(!chordFormatting)
    }

    public func setChordFormatting(_ chordFormattingFlag: Bool) {
        chordFormatting = chordFormattingFlag
        NotificationCenter.default.post(name: .didChangeChordFormatting, object: nil, userInfo: ["value": chordFormatting])
        chordFormattingMenuItem.title = chordFormattingFlag ? "Disable Chord Formatting" : "Enable Chord Formatting"
    }
}
