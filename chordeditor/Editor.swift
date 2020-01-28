import AppKit

class Editor: NSTextView {
    override func insertText(_ insertString: Any) {
        super.insertText(insertString);
        
        if let insertString = insertString as? String {
            // if the insert string isn't one character in length, it cannot be a brace character
            if insertString.count != 1 {
                return;
            }
            
            if insertString.hasPrefix("(") {
                super.insertText(")")
            } else if insertString.hasPrefix("{") {
                super.insertText("}")
            } else if insertString.hasPrefix("[") {
                super.insertText("]")
            } else {
                return;
            }
            
            // adjust the selected range since we inserted an extra character
            self.setSelectedRange(NSMakeRange(self.selectedRange.location - 1, 0))
        }
    }
}
