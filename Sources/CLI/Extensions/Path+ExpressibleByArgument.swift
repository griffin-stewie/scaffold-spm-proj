//
//  Path+Extension.swift
//
//  Created by griffin-stewie on 2021/02/13.
//
//

import ArgumentParser
import Foundation
import Path

extension Path: ExpressibleByArgument {

    /// Initializer to confirm `ExpressibleByArgument`
    public init?(argument: String) {
        self = Path(argument) ?? Path.cwd / argument
    }

    /// `defaultValueDescription` to confirm `ExpressibleByArgument`
    public var defaultValueDescription: String {
        if self == Path.cwd / "." {
            return "current directory"
        }

        return String(describing: self)
    }
}
