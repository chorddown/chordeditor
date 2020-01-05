import Foundation

private let autocompleteMap = [
    "[": "]",
]

class AutoComplete {
    func isHotkey(text: String) -> Bool {
        return autocompleteMap[text] != nil
    }

    func insertedHotkey(text: String, editedRange: NSRange) -> Bool {
        debugPrint("lic", getLastInsertedCharacter(text, editedRange))
        if let insertedString = getLastInsertedCharacter(text, editedRange) {
            return autocompleteMap[insertedString] != nil
        }
        return false
    }

    func autocomplete(text: String, editedRange: NSRange) -> String? {
        let insertedString = getFirstInsertedCharacter(text, editedRange)
        debugPrint("lic", insertedString)
        if let insertedString = getFirstInsertedCharacter(text, editedRange),
            let result = autocompleteMap[insertedString] {
            return ""
                + substring_start(text, editedRange.lowerBound + 1)
                + result
                + substring_end(text, editedRange.lowerBound + 1)
        } else {
            return nil
        }
    }

    func getSuggestions(text: String, editedRange: NSRange) -> [String] {
        let insertedText = getInsertedText(text, editedRange)

        let notes = ["C", "D", "E", "F", "G", "A", "H"]

        var chordSuggestions: [String] = []
        for note in notes {
            chordSuggestions.append(note)
            chordSuggestions.append(note + "m")
        }

        return chordSuggestions.map { insertedText + $0 + "]" }
    }

    private func getInsertedText(_ text: String, _ editedRange: NSRange) -> String {
        return substring(text, range: editedRange)
    }

    private func getLastInsertedCharacter(_ text: String, _ editedRange: NSRange) -> String? {
        if let last = substring(text, range: editedRange).last {
            return String(last)
        } else {
            return nil
        }
    }

    private func getFirstInsertedCharacter(_ text: String, _ editedRange: NSRange) -> String? {
        if let first = substring(text, range: editedRange).first {
            return String(first)
        } else {
            return nil
        }
    }
}
