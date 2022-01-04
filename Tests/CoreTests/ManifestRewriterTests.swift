import XCTest
@testable import Core
import TSCBasic
import PackageModel

final class ManifestRewriterTests: XCTestCase {
    let inputManifestContent: String = """
    // swift-tools-version:5.5
    // The swift-tools-version declares the minimum version of Swift required to build this package.

    import PackageDescription

    let package = Package(
        name: "Package",
        products: [
            // Products define the executables and libraries a package produces, and make them visible to other packages.
            .library(
                name: "Package",
                targets: ["Package"]),
        ],
        dependencies: [
            // Dependencies declare other packages that this package depends on.
            // .package(url: /* package url */, from: "1.0.0"),
        ],
        targets: [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages this package depends on.
            .target(
                name: "Package",
                dependencies: []),
            .testTarget(
                name: "PackageTests",
                dependencies: ["Package"]),
        ]
    )

    """

    let rootDirectoryPath = AbsolutePath("/Original/Package")
    lazy var manifestPath = rootDirectoryPath.appending(component: Manifest.filename)

    var fileSystem: InMemoryFileSystem = InMemoryFileSystem()

    override func setUp() {
        fileSystem = InMemoryFileSystem()
        try! fileSystem.createDirectory(rootDirectoryPath, recursive: true)
        try! fileSystem.writeFileContents(manifestPath, bytes: ByteString(Array(inputManifestContent.utf8)))
    }

    func testReGenerateWithNoModified() throws {
        let testRoot = AbsolutePath("/testReGenerate/Package")
        try! fileSystem.createDirectory(testRoot, recursive: true)
        let rewritedManifestPath = testRoot.appending(component: Manifest.filename)

        let rewriter = try ManifestRewriter(fileSystem: fileSystem, packagePath: rootDirectoryPath)
        try rewriter.write(to: rewritedManifestPath)
        let rewritedManifestContent = try fileSystem.readFileContents(rewritedManifestPath).cString

        XCTAssertEqual(rewritedManifestContent, inputManifestContent)
    }

    func testRewrite() throws {
        let expectedManifestContent: String = """
        // swift-tools-version:5.5
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "Package",
            products: [
                // Products define the executables and libraries a package produces, and make them visible to other packages.
                .library(
                    name: "Package",
                    targets: ["Package"]),
            ],
            dependencies: [
                // Dependencies declare other packages that this package depends on.
                // .package(url: /* package url */, from: "1.0.0"),
            ],
            targets: [
                // Targets are the basic building blocks of a package. A target can define a module or a test suite.
                // Targets can depend on other targets in this package, and on products in packages this package depends on.
                .target(
                    name: "Package",
                    dependencies: []),
                .target(
                    name: "Core",
                    dependencies: []),
                .testTarget(
                    name: "PackageTests",
                    dependencies: ["Package"]),
            ]
        )
        
        """

        let testRoot = AbsolutePath("/testReGenerate/Package")
        try! fileSystem.createDirectory(testRoot, recursive: true)
        let rewritedManifestPath = testRoot.appending(component: Manifest.filename)

        var rewriter = try ManifestRewriter(fileSystem: fileSystem, packagePath: rootDirectoryPath)
        try rewriter.addTargets(names: ["Core"])
        try rewriter.write(to: rewritedManifestPath)

        let rewritedManifestContent = try fileSystem.readFileContents(rewritedManifestPath).cString

        XCTAssertEqual(rewritedManifestContent, expectedManifestContent)
    }
}
