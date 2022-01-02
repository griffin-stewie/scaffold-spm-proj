//
//  Path+Extension.swift
//
//  Created by griffin-stewie on 2021/02/13.
//  
//

import Foundation
import ArgumentParser
import Path

extension Path: ExpressibleByArgument {
    public init?(argument: String) {
        self = Path(argument) ?? Path.cwd/argument
    }

    public var defaultValueDescription: String {
        if self == Path.cwd/"." {
            return "current directory"
        }

        return String(describing: self)
    }
}
