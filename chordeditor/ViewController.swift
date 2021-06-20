import Cocoa

class ViewController: NSViewController, NSTextStorageDelegate, NSTextViewDelegate {
    @IBOutlet var textView: Editor?
    @IBOutlet var chordInsertModeButton: NSButton?
    @IBOutlet var chordFormattingButton: NSButton?

    let autoComplete = AutoComplete()
    let sourceColorizer = SourceColorizer()
    var colorizedText: NSAttributedString?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(interfaceModeChanged(sender:)), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
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
        chordFormattingButton?.isEnabled = false

        NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeChordInsertMode(_:)), name: .didChangeChordInsertMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeChordFormatting(_:)), name: .didChangeChordFormatting, object: nil)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func showHelp(sender _: Any) {
        let storyboard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
        let helpPopup = storyboard.instantiateController(withIdentifier: "helpPopup")

        if let helpPopup = helpPopup as? HelpPopupViewController {
//        helpPopup.preferredContentSize = CGSize(width: 300, height: 300)
            presentAsSheet(helpPopup)
        }
    }

    @IBAction func changeChordInsertModeButton(_ sender: NSButton) {
        let isActive = sender.state == NSControl.StateValue.on
        dump(isActive
            ? "Chord Insert Mode is ON"
            : "Chord Insert Mode is OFF")
        getDelegate().setChordInsertMode(isActive)
    }

    @IBAction func changeChordInsertUpperCaseFirstButton(_ sender: NSButton) {
        let isActive = sender.state == NSControl.StateValue.on
        dump(isActive
            ? "Chord Formatting is ON"
            : "Chord Formatting is OFF")
        getDelegate().setChordFormatting(isActive)
    }

    @objc func onDidChangeChordInsertMode(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let value = userInfo["value"] else {
            return
        }
        let isEnabled = value as! Bool
        chordInsertModeButton?.state = isEnabled ? NSControl.StateValue.on : NSControl.StateValue.off
        chordFormattingButton?.isEnabled = isEnabled
    }

    @objc func onDidChangeChordFormatting(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let value = userInfo["value"] else {
            return
        }
        chordFormattingButton?.state = value as! Bool ? NSControl.StateValue.on : NSControl.StateValue.off
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

    func textView(_ textView: NSTextView, completions _: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem _: UnsafeMutablePointer<Int>?) -> [String] {
        autoComplete.getSuggestions(text: textView.string, editedRange: charRange)
    }

    @objc func interfaceModeChanged(sender _: NSNotification) {
        resetEditor()
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

    private func getDelegate() -> AppDelegate {
        NSApplication.shared.delegate as! AppDelegate
    }
}
