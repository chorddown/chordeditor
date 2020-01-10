import Cocoa

// TODO: Add font license https://github.com/EbenSorkin/Merriweather/blob/master/OFL.txt
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        // Insert code here to initialize your application
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
}
