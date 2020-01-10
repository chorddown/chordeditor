import Cocoa

func getDefaultDocumentContent () -> String {
     return NSLocalizedString("chorddown.defaultContent", tableName: nil, bundle: Bundle.main, value: "", comment: "")
}

class Document: NSDocument {
    var source: String?
    var viewController: ViewController? {
        return windowControllers[0].contentViewController as? ViewController
    }

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    convenience init(type typeName: String) throws {
        self.init()
        fileType = typeName
        source = getDefaultDocumentContent()
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as? NSWindowController {
            addWindowController(windowController)
        }
    }

    override func data(ofType _: String) throws -> Data {
        // Save the text view contents to disk
        guard let textView = viewController?.textView else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }

        if let data = textView.string.data(using: .utf8) {
            return data
        }

        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType _: String) throws {
        source = String(decoding: data, as: UTF8.self)
    }
}
