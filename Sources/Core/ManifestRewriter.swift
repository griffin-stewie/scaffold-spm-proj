import Foundation
import TSCBasic
import Workspace
import Basics
import PackageModel

public struct ManifestRewriter {

    public static let fileName: String = Manifest.filename

    let fileSystem: FileSystem

    let packagePath: AbsolutePath

    var manifest: Manifest

    public init(fileSystem: FileSystem = localFileSystem, packagePath: AbsolutePath) throws {
        self.fileSystem = fileSystem
        self.packagePath = packagePath

        let swiftCompiler: AbsolutePath = {
            let string: String
            #if os(macOS)
            string = try! Process.checkNonZeroExit(args: "xcrun", "--sdk", "macosx", "-f", "swiftc").spm_chomp()
            #else
            string = try! Process.checkNonZeroExit(args: "which", "swiftc").spm_chomp()
            #endif
            return AbsolutePath(string)
        }()
        let identityResolver = DefaultIdentityResolver()
        manifest = try tsc_await { ManifestLoader.loadRootManifest(at: packagePath, swiftCompiler: swiftCompiler, swiftCompilerFlags: [], identityResolver: identityResolver, fileSystem: fileSystem, on: .global(), completion: $0) }
    }

    public mutating func addTargets(names: [String]) throws {
        if names.isEmpty {
            return
        }

        let products = manifest.products.map({ $0.name }).joined(separator: ", ")
        print("Products:", products)

        let newTargets = try names.map { try TargetDescription(name: $0, dependencies: [], type: .regular) }
        manifest = manifest.copyAppending(newTargets: newTargets)

        let targets = manifest.targets.map({ $0.name }).joined(separator: ", ")
        print("Targets:", targets)
    }

    public func write(to destination: AbsolutePath) throws {
        try manifest.write(to: destination, fileSystem: fileSystem)
    }
}

extension Manifest {
    func copyAppending(newTargets: [TargetDescription]) -> Self {
        return Self.init(name: name, path: path, packageKind: packageKind, packageLocation: packageLocation, defaultLocalization: defaultLocalization, platforms: platforms, version: version, revision: revision, toolsVersion: toolsVersion, pkgConfig: pkgConfig, providers: providers, cLanguageStandard: cLanguageStandard, cxxLanguageStandard: cxxLanguageStandard, swiftLanguageVersions: swiftLanguageVersions, dependencies: dependencies, products: products, targets: targets + newTargets)
    }

    func write(to destination: AbsolutePath, fileSystem: FileSystem = localFileSystem) throws {
        if fileSystem.exists(destination) {
            try fileSystem.removeFileTree(destination)
        }

        try writePackageFile(destination, fileSystem: fileSystem) { stream in
            stream <<< """
                // The swift-tools-version declares the minimum version of Swift required to build this package.

                import PackageDescription

                let package = Package(

                """

            var pkgParams = [String]()
            pkgParams.append("""
                    name: "\(name)"
                """)

            var platformsParams = [String]()
            for supportedPlatform in platforms {
                let version = supportedPlatform.version
                let platform = supportedPlatform.platformName

                var param = ".\(platform)("
//                if supportedPlatform.isManifestAPIAvailable {
//                    if version.minor > 0 {
//                        param += ".v\(version.major)_\(version.minor)"
//                    } else {
//                        param += ".v\(version.major)"
//                    }
//                } else {
//                    param += "\"\(version.versionString)\""
//                }
                param += ")"

                platformsParams.append(param)
            }

            if !platforms.isEmpty {
                pkgParams.append("""
                        platforms: [\(platformsParams.joined(separator: ", "))]
                    """)
            }

            if !products.isEmpty {

                var productsParams: [String] = []

                productsParams.append("""
                    products: [
                        // Products define the executables and libraries a package produces, and make them visible to other packages.
                """)

                if products.count == 1 {
                    let product = products[0]
                    productsParams.append("""
                            .library(
                                name: "\(product.name)",
                                targets: ["\(product.name)"]),
                    """)
                    productsParams.append("    ]")
                } else {
                    for product in products {
                        switch product.type {
                        case .library(.automatic):
                            pkgParams.append("        .library(")
                        default:
                            break
                        }

                        pkgParams.append("            name: \"\(product.name)\",")
                        pkgParams.append("            targets: [")



                        for target in product.targets {
                            pkgParams.append("        \"\(target)\",")
                        }
                        pkgParams.append("    ]),")

                    }

                    pkgParams.append("    ]")
                }

                pkgParams.append(productsParams.joined(separator: "\n"))
            }


            if dependencies.isEmpty {
                pkgParams.append("""
                        dependencies: [
                            // Dependencies declare other packages that this package depends on.
                            // .package(url: /* package url */, from: "1.0.0"),
                        ]
                    """)
            } else {

            }

            if targets.isEmpty {
                pkgParams.append("""
                        targets: [
                            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
                            // Targets can depend on other targets in this package, and on products in packages this package depends on.
                        ]
                    """)
            } else {
                var targetsParams: [String] = []
                targetsParams.append("""
                        targets: [
                            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
                            // Targets can depend on other targets in this package, and on products in packages this package depends on.
                    """)

                for target in targets.sorted() {
                    targetsParams.append("""
                                    .\(target.functionName())(
                                        name: "\(target.name)",
                            """)
                    if target.dependencies.isEmpty {
                        targetsParams.append("""
                                            dependencies: []),
                                """)
                    } else {
                        if target.dependencies.count == 1 {
                            var content = ""
                            let dependency = target.dependencies[0]
                            switch dependency {
                            case .byName(name: let name, condition: nil):
                                content = name
                            case .byName(name: _, condition: _):
                                content = "\(dependency)"
                            default:
                                fatalError("not supported now")
                            }
                            targetsParams.append("""
                                                    dependencies: ["\(content)"]),
                                        """)
                        } else {
                            fatalError("not supported now")
                        }
                    }
                }

                targetsParams.append("    ]")
                pkgParams.append(targetsParams.joined(separator: "\n"))
            }

            stream <<< pkgParams.joined(separator: ",\n") <<< "\n)\n"
        }

        
        let version = InitPackage.newPackageToolsVersion.zeroedPatch

        // Write the current tools version.
        try writeToolsVersion(at: destination.parentDirectory, version: version, fs: fileSystem)
    }

    private func writePackageFile(_ path: AbsolutePath, fileSystem: FileSystem = localFileSystem, body: (OutputByteStream) -> Void) throws {
        try fileSystem.writeFileContents(path, body: body)
    }
}

extension Array where Element == TargetDescription {
    func sorted() -> Self {
        return [
            filter { target in
                target.type == .executable
            },
            filter { target in
                target.type == .regular
            },
            filter { target in
                target.type == .test
            },
            filter { target in
                target.type == .system
            },
            filter { target in
                target.type == .binary
            },
            filter { target in
                target.type == .plugin
            },
        ]
            .flatMap({ $0 })
    }
}

extension TargetDescription {
    func functionName() -> String {
        switch self.type {
        case .regular:
            return "target"
        case .executable:
            return "executableTarget"
        case .test:
            return "testTarget"
        case .system:
            return "systemLibrary"
        case .binary:
            return "binaryTarget"
        case .plugin:
            return "plugin"
        }
    }
}
