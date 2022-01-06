import Foundation

/// Runtime Error
public struct RuntimeError: Error, CustomStringConvertible {

    /// description of error
    public var description: String

    /// Initializer
    /// - Parameter description: description of error
    public init(_ description: String) {
        self.description = description
    }
}
