import Darwin

/// stderr
public struct StandardError: TextOutputStream {

    /// Confirm to `TextOutputStream`
    /// - Parameter string: write to.
    public mutating func write(_ string: String) {
        for byte in string.utf8 { putc(numericCast(byte), stderr) }
    }
}
