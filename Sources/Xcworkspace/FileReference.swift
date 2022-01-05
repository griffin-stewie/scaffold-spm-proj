//
//  FileReference.swift
//
//
//  Created by griffin-stewie on 2022/01/01.
//
//

import Foundation
import System

public struct FileReference {

    private let type: String = "group"

    public let location: FilePath

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
