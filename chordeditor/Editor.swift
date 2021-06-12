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
    
    override func paste(_ : Any?) {
        let pasteboard = NSPasteboard.general
        guard let pasteboardString = pasteboard.string(forType: .string) else { return }
        
        // Remove carriage return from pasted strings
        let cleanString = String(pasteboardString.replacingOccurrences(of: "\r", with: ""))
        insertText(cleanString, replacementRange: NSMakeRange(NSNotFound, 0))
    }

    override func insertText(_ insertString: Any, replacementRange: NSRange) {
        if let insertString = insertString as? String {
            let didInsertClosing = insertClosingIfApplicable(insertString: insertString, replacementRange: replacementRange)
            if didInsertClosing {
                return
            }

            if chordInsertMode != true {
                super.insertText(insertString, replacementRange: replacementRange)
                return
            }

            let selectedRange = selectedRanges.first!.rangeValue
            let result = prepareInsertedChordString(currentText: string, insertChordString: insertString, selectedRange: selectedRange, chordFormatting: chordFormatting)
            super.insertText(result.insertChordString, replacementRange: replacementRange)
            setSelectedRange(result.selectedRange)
        }
    }

    func insertClosing(insertString: String, closing: String, replacementRange: NSRange) {
        super.insertText(insertString, replacementRange: replacementRange)
        super.insertText(closing, replacementRange: replacementRange)
        setSelectedRange(NSMakeRange(selectedRange.location - 1, 0))
    }

    func insertClosingIfApplicable(insertString: String, replacementRange: NSRange) -> Bool {
        for (key, closing) in wrappingStrings {
            if insertString.hasPrefix(key) {
                insertClosing(insertString: insertString, closing: closing, replacementRange: replacementRange)
                return true
            }
        }
        return false
    }

    private func getDelegate() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
}
