import AppKit

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

    override func insertText(_ insertString: Any) {
        if let insertString = insertString as? String {
            // if the insert string isn't one character in length, it cannot be a brace character
            if insertString.count != 1 {
                return
            }

            if insertString.hasPrefix("(") {
                insertClosing(insertString: insertString, closing: ")")
            } else if insertString.hasPrefix("{") {
                insertClosing(insertString: insertString, closing: "}")
            } else if insertString.hasPrefix("[") {
                insertClosing(insertString: insertString, closing: "]")
            } else if chordInsertModeActive != nil, chordInsertModeActive == true {
                let sectionLength = 100
                var location = selectedRange.location
                if location < sectionLength {
                    location = 0
                } else {
                    location -= sectionLength
                }
                let lastPortion = substring(string, range: NSMakeRange(location, sectionLength))
                if shouldWrapText(text: lastPortion, insertString: insertString) {
                    super.insertText("[" + insertString + "]")
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
        setSelectedRange(NSMakeRange(selectedRange.location, 0))
    }
}
