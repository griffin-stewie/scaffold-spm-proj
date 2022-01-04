import Foundation
import Path
import TSCBasic

extension Pathish {
    public func absolutePath() -> AbsolutePath {
        AbsolutePath(self.string)
    }
}
