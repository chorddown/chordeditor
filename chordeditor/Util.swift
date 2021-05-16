import AppKit

extension NSColor {
    // Use: NSColor("ffffff")
    convenience init(_ hex: String) {
        if let hexInt = Int(hex.lowercased(), radix: 16) {
            self.init(hex: hexInt)
        } else {
            self.init(hex: 0)
        }
    }

    // Use: NSColor(hex: 0xffffffff)
    convenience init(hex: Int) {
        var opacity: CGFloat = 1.0
        if hex > 0xFFFFFF {
            opacity = CGFloat((hex >> 24) & 0xFF) / 255
        }
        let parts = (
            R: CGFloat((hex >> 16) & 0xFF) / 255,
            G: CGFloat((hex >> 08) & 0xFF) / 255,
            B: CGFloat((hex >> 00) & 0xFF) / 255,
            A: opacity
        )
        // print(parts)
        self.init(red: parts.R, green: parts.G, blue: parts.B, alpha: parts.A)
    }

    // Use: NSColor(RGB:(128,255,255))
    convenience init(RGB: (Int, Int, Int)) {
        self.init(
            red: CGFloat(RGB.0) / 255,
            green: CGFloat(RGB.1) / 255,
            blue: CGFloat(RGB.2) / 255,
            alpha: 1.0
        )
    }
}

/// Debounce & Throttling
/// https://gist.github.com/simme/b78d10f0b29325743a18c905c5512788
extension TimeInterval {
    /// Checks if `since` has passed since `self`.
    ///
    /// - Parameter since: The duration of time that needs to have passed for this function to return `true`.
    /// - Returns: `true` if `since` has passed since now.
    func hasPassed(since: TimeInterval) -> Bool {
        return Date().timeIntervalSinceReferenceDate - self > since
    }
}

/// Wraps a function in a new function that will throttle the execution to once in every `delay` seconds.
///
/// - Parameter delay: A `TimeInterval` specifying the number of seconds that needst to pass between each execution of `action`.
/// - Parameter queue: The queue to perform the action on. Defaults to the main queue.
/// - Parameter action: A function to throttle.
/// - Returns: A new function that will only call `action` once every `delay` seconds, regardless of how often it is called.
func throttle(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
    var currentWorkItem: DispatchWorkItem?
    var lastFire: TimeInterval = 0
    return {
        guard currentWorkItem == nil else { return }
        currentWorkItem = DispatchWorkItem {
            action()
            lastFire = Date().timeIntervalSinceReferenceDate
            currentWorkItem = nil
        }
        delay.hasPassed(since: lastFire) ? queue.async(execute: currentWorkItem!) : queue.asyncAfter(deadline: .now() + delay, execute: currentWorkItem!)
    }
}

class Throttler {
    let delay: TimeInterval
    let queue: DispatchQueue

    var currentWorkItem: DispatchWorkItem?
    var lastFire: TimeInterval = 0

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func throttle(action: @escaping (() -> Void)) {
        guard currentWorkItem == nil else { return }
        currentWorkItem = DispatchWorkItem {
            action()
            self.lastFire = Date().timeIntervalSinceReferenceDate
            self.currentWorkItem = nil
        }
        delay.hasPassed(since: lastFire)
            ? queue.async(execute: currentWorkItem!)
            : queue.asyncAfter(deadline: .now() + delay, execute: currentWorkItem!)
    }
}

func substring(_ str: String, from: UInt, length: UInt) -> String {
    if length == 0 {
        return ""
    } else {
        return String(str.dropFirst(Int(from)).prefix(Int(length)))
    }
}

func substring(_ str: String, range: NSRange) -> String {
    if range.length == 0 {
        return ""
    }
    let start = str.index(str.startIndex, offsetBy: range.lowerBound)
    let end = str.index(str.startIndex, offsetBy: range.upperBound)
    let index_range = start ..< end

    return String(str[index_range])

    // return substring(str, from: UInt(range.lowerBound), length: UInt(range.upperBound - range.lowerBound))
}

func substring_start(_ str: String, _ to: Int) -> String {
    return String(str.prefix(to))
}

func substring_end(_ str: String, _ from: Int) -> String {
    return String(str.dropFirst(from))
}
