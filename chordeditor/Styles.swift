import AppKit

private let pink = #colorLiteral(red: 1, green: 0.1764705882, blue: 0.3333333333, alpha: 1)
private let blue = #colorLiteral(red: 0, green: 0.4078431373, blue: 0.8549019608, alpha: 1)
private let green = NSColor("239b32")
private let greenDark = NSColor("187123")
private let gray = NSColor("cccccc")
private let grayDark = NSColor("8d8d88")

private let fcGreen = EditorStyle(key: NSAttributedString.Key.foregroundColor, value: green)
private let fcGrayDark = EditorStyle(key: NSAttributedString.Key.foregroundColor, value: grayDark)

private func defaultFontStyle(_ size: CGFloat = 14) -> EditorStyle {
    return EditorStyle(key: NSAttributedString.Key.font, value: Styles.defaultFont(size))
}

private enum InterfaceStyle: String {
    case Dark, Light

    init() {
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"

        self = InterfaceStyle(rawValue: type)!
    }
}

/// A style-rule consisting of a `NSAttributedString.Key` and the corresponding value
class EditorStyle {
    let key: NSAttributedString.Key
    let value: Any

    init(key: NSAttributedString.Key, value: Any) {
        self.key = key
        self.value = value
    }
}

class Styles {
    static func defaultStyles() -> [EditorStyle] {
        return [
            defaultFontStyle(),
            EditorStyle(key: NSAttributedString.Key.foregroundColor, value: self.defaultForegroundColor()),
            EditorStyle(key: NSAttributedString.Key.paragraphStyle, value: self.defaultParagraphStyle()),
        ]
    }

    static func defaultParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = 5

        return style
    }

    static func headerParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = 10

        return style
    }

    static func commentParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        // style.lineSpacing = 30
        style.paragraphSpacing = 5

        return style
    }

    static func defaultForegroundColor() -> NSColor {
        if InterfaceStyle() == .Dark {
            return NSColor("EEEEEE")
        } else {
            return NSColor("221d1c")
        }
    }

    static func defaultBackgroundColor() -> NSColor {
        if InterfaceStyle() == .Dark {
            return NSColor("333333")
        } else {
            return NSColor("FFFFFF")
        }
    }

    static func defaultFont(_ size: CGFloat = 14) -> NSFont {
        if let font = NSFont(name: "Merriweather-Regular", size: size) {
            return font
        } else {
            fatalError("[ERROR] Font 'Merriweather-Regular' not found")
        }
    }

    static func defaultMonospacedFont(_ size: CGFloat = 14) -> NSFont {
        if #available(OSX 10.15, *) {
            return NSFont.monospacedSystemFont(ofSize: size, weight: NSFont.Weight.regular)
        } else {
            if let font = NSFont(name: "Menlo", size: size) {
                return font
            } else {
                fatalError("[ERROR] Font 'Menlo' not found")
            }
        }
    }

    static func patternToStyleMap() -> [String: [EditorStyle]] {
        return [
            /// # Character styles

            /// Chord
            #"\[([^\]]*)\]"#: [
                fcGreen,
            ],

            /// Code
            #"`.*`"#: [
                EditorStyle(key: NSAttributedString.Key.foregroundColor, value: NSColor.systemGray),
                EditorStyle(key: NSAttributedString.Key.font, value: defaultMonospacedFont()),
            ],

            /// # Block styles

            /// Comment
            #"^>.*$"#: [
                EditorStyle(key: NSAttributedString.Key.paragraphStyle, value: Styles.commentParagraphStyle()),
                fcGrayDark,
                defaultFontStyle(24),
            ],

            /// H1
            #"^#[^#].*$"#: [
                EditorStyle(key: NSAttributedString.Key.paragraphStyle, value: Styles.headerParagraphStyle()),
                defaultFontStyle(32),
                fcGrayDark,
            ],

            /// H2
            #"^##[^#].*$"#: [
                EditorStyle(key: NSAttributedString.Key.paragraphStyle, value: Styles.headerParagraphStyle()),
                defaultFontStyle(24),
            ],

            /// Chorus
            #"^##\s?!.*$"#: [
                EditorStyle(key: NSAttributedString.Key.paragraphStyle, value: Styles.headerParagraphStyle()),
                defaultFontStyle(24),
                fcGreen,
            ],

            /// Bridge
            #"^##\s?-.*$"#: [
                EditorStyle(key: NSAttributedString.Key.paragraphStyle, value: Styles.headerParagraphStyle()),
                defaultFontStyle(24),
                EditorStyle(key: NSAttributedString.Key.foregroundColor, value: greenDark),
            ],

            /// H3
            #"^###[^#].*$"#: [
                EditorStyle(key: NSAttributedString.Key.paragraphStyle, value: Styles.headerParagraphStyle()),
                defaultFontStyle(20),
            ],

            /// Meta
            #"^\w+:\s*.*"#: [
                EditorStyle(key: NSAttributedString.Key.foregroundColor, value: blue),
            ],
        ]
    }
}
