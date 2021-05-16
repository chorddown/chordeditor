import AppKit

let wrappingStrings = [
    "(": ")",
    "[": "]",
    "{": "}",
    "\"": "\"",
    "'": "'",
    "`": "`",
]

func capitalizingFirstLetter(_ text: String) -> String {
    return text.prefix(1).uppercased() + text.lowercased().dropFirst()
}

func shouldWrapText(text: String, insertString: String) -> Bool {
    if insertString.range(of: #"^[:alnum:]+$"#, options: .regularExpression) == nil {
        return false
    }

    // If there is no opening bracket yet, insert one
    if !text.contains("[") {
        return true
    }

    // If there are opening and closing brackets in the text, check if the last opening braket has
    // already been closed. If that is the case we should wrap the new character
    let lastOpeningBracket: Range<String.Index> = text.range(of: "[", options: .backwards)!
    if let lastClosingBracket: Range<String.Index> = text.range(of: "]", options: .backwards) {
        return lastOpeningBracket.lowerBound < lastClosingBracket.lowerBound
    }

    return false
}

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
                var sampleLength = 100
                let cursorPosition = selectedRange.location

                var sampleStart: Int
                if cursorPosition < sampleLength {
                    // Get the portion from the file start up to the cursor position
                    sampleLength = cursorPosition
                    sampleStart = 0
                } else {
                    sampleStart = cursorPosition - sampleLength
                }

                var sampleEnd = min(sampleStart + sampleLength - 1, string.count)
                if sampleEnd < 0 {
                    sampleEnd = 0
                }

                let range = NSMakeRange(sampleStart, sampleEnd - sampleStart)
                let sample = substring(string, range: range) + insertString

                if shouldWrapText(text: sample, insertString: insertString) {
                    if chordFormatting == true {
                        super.insertText("[" + capitalizingFirstLetter(insertString) + "]")
                    } else {
                        super.insertText("[" + insertString + "]")
                    }
                    setSelectedRange(NSMakeRange(selectedRange.location - 1, 0))
                } else {
                    super.insertText(insertString)
                }
            } else {
                super.insertText(insertString)
                return
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
