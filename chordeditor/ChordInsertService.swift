import Foundation

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

struct ChordInsertResult {
    let insertChordString: String
    let selectedRange: NSRange
}

/// - Parameter currentText: The characters of the receiver’s text
/// - Parameter insertChordString: The characters that should be inserted
/// - Parameter selectedRange: Currently selected text inside `string`
/// - Parameter chordFormatting: Defines if the inserted chord string should be formatted
func prepareInsertedChordString(currentText: String, insertChordString: String, selectedRange: NSRange, chordFormatting: Bool) -> ChordInsertResult {
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

    var sampleEnd = min(sampleStart + sampleLength - 1, currentText.count)
    if sampleEnd < 0 {
        sampleEnd = 0
    }

    let range = NSMakeRange(sampleStart, sampleEnd - sampleStart)
    let sample = substring(currentText, range: range) + insertChordString

    if shouldWrapText(text: sample, insertString: insertChordString) {
        let newRange = NSMakeRange(selectedRange.location - 1, 0)
        if chordFormatting == true {
            return ChordInsertResult(insertChordString: "[" + capitalizingFirstLetter(insertChordString) + "]", selectedRange: newRange)
        } else {
            return ChordInsertResult(insertChordString: "[" + insertChordString + "]", selectedRange: newRange)
        }
    } else {
        return ChordInsertResult(insertChordString: insertChordString, selectedRange: selectedRange)
    }
}
