//
//  FileReference.swift
//
//
//  Created by griffin-stewie on 2022/01/01.
//
//

import Foundation
import System

/// FileReference node for xcworkspace
public struct FileReference {

    private let type: String = "group"

    /// File path where the contents located
    public let location: FilePath

    /// Initializer
    /// - Parameter location: File path where the contents located
    public init(location: FilePath) {
        self.location = location
    }
}

extension FileReference {
    func toXMLNode() -> XMLNode {
        let element = XMLElement(kind: .element)
        element.name = "FileRef"

        let attr = XMLNode(kind: .attribute)
        attr.name = "location"
        attr.stringValue = "\(type):\(String(decoding: location))"
        element.addAttribute(attr)

        return element
    }
}
