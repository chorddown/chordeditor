import AppKit

let wrappingStrings = [
    "(": ")",
    "[": "]",
    "{": "}",
    "\"": "\"",
    "'": "'",
    "`": "`",
]

class Editor: NSTextView {
    var chordInsertMode: Bool {
        return getDelegate().chordInsertMode
    }

    var chordFormatting: Bool {
        return getDelegate().chordFormatting
    }

    override func insertText(_ insertString: Any) {
        if let insertString = insertString as? String {
            // if the insert string isn't one character in length, it cannot be a brace character
            if insertString.count != 1 {
                return
            }

            let didInsertClosing = insertClosingIfApplicable(insertString: insertString)
            if didInsertClosing {
                return
            }
            if chordInsertMode == true {
                let result = prepareInsertedChordString(currentText: string, insertChordString: insertString, selectedRange: selectedRange, chordFormatting: chordFormatting)
                setSelectedRange(result.selectedRange)
                super.insertText(result.insertChordString)
            } else {
                super.insertText(insertString)
            }
        }
    }

    func insertClosing(insertString: String, closing: String) {
        super.insertText(insertString)
        super.insertText(closing)
        setSelectedRange(NSMakeRange(selectedRange.location - 1, 0))
    }

    func insertClosingIfApplicable(insertString: String) -> Bool {
        for (key, closing) in wrappingStrings {
            if insertString.hasPrefix(key) {
                insertClosing(insertString: insertString, closing: closing)
                return true
            }
        }
        return false
    }

    private func getDelegate() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
}
