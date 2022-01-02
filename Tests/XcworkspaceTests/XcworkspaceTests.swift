import XCTest
@testable import Xcworkspace
import Path

final class XcworkspaceTests: XCTestCase {
    var xmlString: String = """
    <?xml version="1.0" encoding="UTF-8"?>
    <Workspace
       version = "1.0">
       <FileRef
          location = "group:Sample/Package">
       </FileRef>
       <FileRef
          location = "group:Sample/iOS.xcodeproj">
       </FileRef>
       <FileRef
          location = "group:Sample/macOS.xcodeproj">
       </FileRef>
    </Workspace>
    """

//    func testLoading() throws {
//        try Path.mktemp { path in
//            let filePath = path/"contents.xcworkspacedata"
//            try xmlString.write(to: filePath)
//
//            let workspace = try Xcworkspace(at: filePath.url)
//
//            print(workspace)
//        }
//    }

    func testConstruct() throws {
        var workspace = Xcworkspace()
        workspace.append(FileReference(location: "Sample/Package"))
        workspace.append(FileReference(location: "Sample/iOS.xcodeproj"))
        workspace.append(FileReference(location: "Sample/macOS.xcodeproj"))
        let generatedData = workspace.xmlDocument().xmlData

        let testData = xmlString.data(using: .utf8)!

        XCTAssertEqual(try XMLDocument(data: generatedData), try XMLDocument(data: testData))
    }
}



class TemporaryDirectory {
    let url: URL
    var path: DynamicPath { return DynamicPath(Path(url.path)!) }

    /**
     Creates a new temporary directory.

     The directory is recursively deleted when this object deallocates.

     If you need a temporary directory on a specific volume use the `appropriateFor`
     parameter.

     - Important: If you are moving a file, ensure to use the `appropriateFor`
     parameter, since it is volume aware and moving the file across volumes will take
     exponentially longer!
     - Important: The `appropriateFor` parameter does not work on Linux.
     - Parameter appropriateFor: The temporary directory will be located on this
     volume.
    */
    init(appropriateFor: URL? = nil) throws {
      #if !os(Linux)
        let appropriate: URL
        if let appropriateFor = appropriateFor {
            appropriate = appropriateFor
        } else if #available(OSX 10.12, iOS 10, tvOS 10, watchOS 3, *) {
            appropriate = FileManager.default.temporaryDirectory
        } else {
            appropriate = URL(fileURLWithPath: NSTemporaryDirectory())
        }
        url = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: appropriate, create: true)
      #else
        let envs = ProcessInfo.processInfo.environment
        let env = envs["TMPDIR"] ?? envs["TEMP"] ?? envs["TMP"] ?? "/tmp"
        let dir = Path.root/env/"swift-sh.XXXXXX"
        var template = [UInt8](dir.string.utf8).map({ Int8($0) }) + [Int8(0)]
        guard mkdtemp(&template) != nil else { throw CocoaError.error(.featureUnsupported) }
        url = URL(fileURLWithPath: String(cString: template))
      #endif
    }

    deinit {
        do {
            try path.chmod(0o777).delete()
        } catch {
            //TODO log
        }
    }
}

extension Path {
    static func mktemp<T>(body: (DynamicPath) throws -> T) throws -> T {
        let tmp = try TemporaryDirectory()
        return try body(tmp.path)
    }
}
