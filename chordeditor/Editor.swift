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

    let openingBracket: Range<String.Index> = text.range(of: "[", options: .backwards)!
    if let closeingBracket: Range<String.Index> = text.range(of: "]", options: .backwards) {
        return openingBracket.lowerBound < closeingBracket.lowerBound
    }

    return false
}

class Editor: NSTextView {
    var chordInsertModeActive: Bool?
    var chordInsertUpperCaseFirst: Bool = true

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
            if chordInsertModeActive == true {
                var sectionLength = 100
                var location = selectedRange.location
                if location < sectionLength {
                    sectionLength = location
                    location = 0
                } else {
                    location -= sectionLength
                }
                let lastPortion = substring(string, range: NSMakeRange(location, sectionLength))
                if shouldWrapText(text: lastPortion, insertString: insertString) {
                    if chordInsertUpperCaseFirst == true {
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
}
