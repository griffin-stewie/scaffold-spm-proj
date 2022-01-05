//
//  Xcworkspace.swift
//
//
//  Created by griffin-stewie on 2022/01/01.
//
//

import Foundation

public struct Xcworkspace {

    var fileReferences: [FileReference] = []

    public init() {

    }

    public mutating func append(_ ref: FileReference) {
        self.fileReferences.append(ref)
    }
}

extension Xcworkspace {

    public func workspaceElement() -> XMLElement {
        let element = XMLElement(name: "Workspace")
        let attr = XMLNode(kind: .attribute)
        attr.name = "version"
        attr.stringValue = "1.0"
        element.addAttribute(attr)
        return element
    }

    public func xmlDocument() -> XMLDocument {
        let root = workspaceElement()

        fileReferences
            .map({ $0.toXMLNode() })
            .forEach({ root.addChild($0) })

        let doc = XMLDocument()
        doc.version = "1.0"
        doc.characterEncoding = "UTF-8"
        doc.setRootElement(root)
        return doc
    }

    public func write(to destination: URL) throws {
        try xmlDocument()
            .xmlData(options: [.nodePrettyPrint])
            .write(to: destination)
    }
}
