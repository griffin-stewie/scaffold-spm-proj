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
