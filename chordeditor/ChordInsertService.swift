import Foundation

func capitalizingFirstLetter(_ text: String) -> String {
    text.prefix(1).uppercased() + text.lowercased().dropFirst()
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

struct ChordInsertResult {
    let insertChordString: String
    let selectedRange: NSRange
}

/// - Parameter currentText: The characters of the receiver’s text
/// - Parameter insertChordString: The characters that should be inserted
/// - Parameter selectedRange: Currently selected text inside `string`
/// - Parameter chordFormatting: Defines if the inserted chord string should be formatted
func prepareInsertedChordString(currentText: String, insertChordString: String, selectedRange: NSRange, chordFormatting: Bool) -> ChordInsertResult {
    let sample = getSample(currentText: currentText, insertChordString: insertChordString, selectedRange: selectedRange)

    if shouldWrapText(text: sample, insertString: insertChordString) {
        let newRange = NSMakeRange(selectedRange.location + insertChordString.count + 1, 0)
        if chordFormatting == true {
            return ChordInsertResult(insertChordString: "[" + capitalizingFirstLetter(insertChordString) + "]", selectedRange: newRange)
        } else {
            return ChordInsertResult(insertChordString: "[" + insertChordString + "]", selectedRange: newRange)
        }
    } else {
        let newRange = NSMakeRange(selectedRange.location + insertChordString.count, 0)

        return ChordInsertResult(insertChordString: insertChordString, selectedRange: newRange)
    }
}

private func getSample(currentText: String, insertChordString: String, selectedRange: NSRange) -> String {
    let sampleLength = 10
    let cursorPosition = selectedRange.location
    let sampleStart = cursorPosition < sampleLength
        ? 0 // Get the portion from the file start up to the cursor position
        : cursorPosition - sampleLength

    let range = NSMakeRange(sampleStart, min(sampleLength, cursorPosition))

    return substring(currentText, range: range) + insertChordString
}
