import Foundation
import Path
import TSCBasic

extension Pathish {

    /// Helper method convert to `AbsolutePath` from `Path`
    /// - Returns: `AbsolutePath` converted from `Path` itself.
    public func absolutePath() -> AbsolutePath {
        AbsolutePath(self.string)
    }
}
