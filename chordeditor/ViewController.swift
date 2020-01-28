import Cocoa

class ViewController: NSViewController, NSTextStorageDelegate, NSTextViewDelegate {
    @IBOutlet var textView: NSTextView?

    let autoComplete = AutoComplete()
    let sourceColorizer = SourceColorizer()
    var colorizedText: NSAttributedString?

    override func viewDidLoad() {
        super.viewDidLoad()
        resetEditor()
    }

    override func viewDidAppear() {
        resetEditor()
        if let document = view.window?.windowController?.document as? Document {
            textView?.textStorage?.setAttributedString(getAttributedString(document))
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    override func textStorageDidProcessEditing(_: Notification) {
        if #available(OSX 10.11, *) {
            /* noop */
        } else {
            colorizeText(nil)
        }
    }

    /// The following is only available on macos 10.11 or higher
    @available(OSX 10.11, *)
    func textStorage(_: NSTextStorage,
                     didProcessEditing editedMask: NSTextStorageEditActions,
                     range: NSRange, changeInLength delta: Int) {
        if delta != 0, editedMask.rawValue > 1 {
            colorizeText(range)
        }
    }

    func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem _: UnsafeMutablePointer<Int>?) -> [String] {
        return autoComplete.getSuggestions(text: textView.string, editedRange: charRange)
    }

    private func colorizeText(_ range: NSRange?) {
        guard let textView = self.textView else {
            debugPrint("[ERROR] textView not defined")
            return
        }
        guard let textStorage = textView.textStorage else {
            debugPrint("[ERROR] textView.textStorage not defined")
            return
        }

        colorizedText = sourceColorizer.colorize(string: textStorage.string, inRange: range)

        textStorage.setAttributedString(colorizedText!)
    }

    private func resetEditor() {
        if let textView = self.textView {
            textView.delegate = self
            textView.isAutomaticQuoteSubstitutionEnabled = false
            textView.isAutomaticDashSubstitutionEnabled = false
            textView.isAutomaticSpellingCorrectionEnabled = false
            textView.isAutomaticLinkDetectionEnabled = false
            textView.textStorage?.delegate = self

            let defaultFont = Styles.defaultFont()
            textView.font = defaultFont
            textView.textStorage?.font = defaultFont

            // Horizontal scroll
            textView.enclosingScrollView?.hasHorizontalScroller = true
            textView.isHorizontallyResizable = true
            textView.autoresizingMask = [.width, .height]
            textView.textContainer?.containerSize = NSSize(width: Int.max, height: Int.max)
            textView.textContainer?.widthTracksTextView = false
            textView.textContainerInset = CGSize(width: 8, height: 10)
            textView.defaultParagraphStyle = Styles.defaultParagraphStyle()

            // Default colors
            textView.backgroundColor = Styles.defaultBackgroundColor()
            textView.textColor = Styles.defaultForegroundColor()
            textView.insertionPointColor = Styles.defaultForegroundColor()
        } else {
            debugPrint("[ERROR] textView is not defined")
        }
    }

    private func getAttributedString(_ document: Document) -> NSAttributedString {
        if let source = document.source {
            return SourceColorizer().colorize(string: source, inRange: nil)
        } else {
            return NSAttributedString(string: "")
        }
    }
}
