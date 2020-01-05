import AppKit

class Editor: NSTextView {
    let autocomplete = AutoComplete()

    override func keyDown(with event: NSEvent) {
//        if let chars = event.characters {
//            if autocomplete.isHotkey(text: chars) {
//                (delegate as! ViewController).requestInternalAutocomplete()
//            }
//        }

        super.keyDown(with: event)
    }
}
