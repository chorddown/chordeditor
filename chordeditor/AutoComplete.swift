import Foundation

class AutoComplete {
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
}
