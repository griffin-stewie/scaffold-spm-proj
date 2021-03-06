//
//  FileManager+Extensions.swift
//
//  Created by griffin-stewie on 2020/03/04.
//

import Foundation

extension FileManager {

    /// Move to specified directory and execute closure
    /// Move back to original location after closure
    /// - Parameters:
    ///   - path: Destination
    ///   - closure: Invoked in the path you gave
    /// - Throws: exception
    public func chdir(_ path: String, closure: () throws -> Void) rethrows {
        let previous = self.currentDirectoryPath
        self.changeCurrentDirectoryPath(path)
        defer { self.changeCurrentDirectoryPath(previous) }
        try closure()
    }


    /// Remove it if it exists
    ///
    /// - Parameter url: File URL you want to remove
    /// - Throws: exception from `removeItem(at:)`
    public func removeItemIfExists(at url: Foundation.URL) throws {
        if self.fileExists(atPath: url.path) {
            try self.removeItem(at: url)
        }
    }

    /// Trash it if it exists
    ///
    /// - Parameter url: File URL you want to throw away
    /// - Throws: exception from `trashItem(at: resultingItemURL:)`
    public func trashItemIfExists(at url: Foundation.URL) throws {
        if self.fileExists(atPath: url.path) {
            try self.trashItem(at: url, resultingItemURL: nil)
        }
    }
}
