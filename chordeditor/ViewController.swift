import Cocoa

class ViewController: NSViewController, NSTextStorageDelegate, NSTextViewDelegate {
    @IBOutlet var textView: NSTextView?

    let autoComplete = AutoComplete()
    let sourceColorizer = SourceColorizer()
    var colorizedText: NSAttributedString?
    var locked: Bool = false
    var selectedRange: NSRange?
    var internalAutocompleteRequested = false
    let throttler = Throttler(delay: 2, queue: .main)

    func requestInternalAutocomplete() {
        internalAutocompleteRequested = true
    }

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
        guard let textView = self.textView else {
            return
        }

        if #available(OSX 10.11, *) {
            /* noop */
        } else {
            colorizeText(nil)

            if internalAutocompleteRequested {
                autocompleteText(range: textView.selectedRange())
                internalAutocompleteRequested = false
            }
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

    @available(OSX 10.11, *)
    func textStorage(_: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if delta != 0, editedMask.rawValue > 1 {
            if internalAutocompleteRequested {
                autocompleteText(range: editedRange)
                internalAutocompleteRequested = false
            }
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

    private func autocompleteText(range editedRange: NSRange) {
        guard locked == false else {
            return
        }

        guard let textView = self.textView else {
            debugPrint("[ERROR] textView not defined")
            return
        }
        guard let textStorage = textView.textStorage else {
            debugPrint("[ERROR] textView.textStorage not defined")
            return
        }

        locked = true

        let originalText = textStorage.string
        if let newText = autoComplete.autocomplete(text: originalText, editedRange: editedRange) {
            colorizedText = sourceColorizer.colorize(string: newText, inRange: editedRange)
            textStorage.setAttributedString(colorizedText!)
        }

        locked = false
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
