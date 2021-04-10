import AppKit

class SourceColorizer {
    func colorize(string input: String, inRange range: NSRange?) -> NSAttributedString {
        let subject = NSMutableAttributedString(string: input)

        colorize(subject: subject, inRange: range)

        return subject
    }

    func colorize(subject: NSMutableAttributedString, inRange _: NSRange?) {
        let completeTextRange = NSRange(location: 0, length: subject.length)
        setStyles(subject, Styles.defaultStyles(), completeTextRange)
        for (regex, styles) in Styles.patternToStyleMap() {
            colorizeByRegex(subject: subject, range: completeTextRange, regex: regex, styles: styles)
        }
    }

    private func colorizeByRegex(
        subject: NSMutableAttributedString,
        range: NSRange,
        regex: String,
        styles: [EditorStyle]
    ) {
        do {
            let regex = try NSRegularExpression(
                pattern: regex,
                options: [NSRegularExpression.Options.anchorsMatchLines, NSRegularExpression.Options.caseInsensitive]
            )

            regex.enumerateMatches(in: subject.string, options: [], range: range) { match, _, _ in
                guard let match = match else { return }

                self.setStyles(subject, styles, match.range)
            }
        } catch {
            print("Unexpected error: \(error)")
            return
        }
    }

    private func setStyles(
        _ subject: NSMutableAttributedString,
        _ styles: [EditorStyle],
        _ range: NSRange
    ) {
        for style in styles {
            subject.addAttribute(style.key, value: style.value, range: range)
        }
    }
}
