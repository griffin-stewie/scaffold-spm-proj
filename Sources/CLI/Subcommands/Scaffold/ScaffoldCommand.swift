import ArgumentParser
import Basics
import Core
import Foundation
import PackageModel
import Path
import System
import TSCBasic
import Workspace
import Xcworkspace

struct ScaffoldCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "scaffold",
        abstract: "Scaffold the hyper-modularized style directories and files structure."
    )

    @OptionGroup()
    var options: ScaffoldCommandOptions

    func run() throws {
        try run(options: options)
        throw ExitCode.success
    }
}

extension ScaffoldCommand {
    private func run(options: ScaffoldCommandOptions) throws {
        print("new command: \(options)")

        let fs = FileManager.default

        // 1. cd options.rootdir
        fs.changeCurrentDirectoryPath(options.destinationDirectory.string)
        print(Path.cwd.string)

        // 1. mkdir options.repositoryName
        try (Path.cwd / options.repositoryName).mkdir()


        // 1. cd options.repositoryName
        fs.changeCurrentDirectoryPath(options.repositoryName)

        // 1. git init
        _ = try Shell.shared.run(arguments: ["git", "init"])

        // 1. touch README.md
        try "# \(options.repositoryName)".write(to: Path.cwd / "README.md")

        if let directoryInto = options.directoryInto {
            let dir = Path.cwd / directoryInto
            try dir.mkdir()
            fs.changeCurrentDirectoryPath(dir.string)
        }

        // 1. mkdir options.xcworkspaceName
        try (Path.cwd / options.resolvedXcworkspaceName()).mkdir()


        // 1. mkdir \(options.xcworkspaceName).xcworkspace
        let xcworkspacePah = try (Path.cwd / "\(options.resolvedXcworkspaceName()).xcworkspace").mkdir()

        // 1. curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/Swift.gitignore
        _ = try tsc_await {
            HTTP.download(url: URL(string: "https://raw.githubusercontent.com/github/gitignore/main/Swift.gitignore")!, to: (Path.cwd / ".gitignore").url, completionHandler: $0)
        }

        // 1. cd options.xcworkspaceName
        fs.changeCurrentDirectoryPath(options.resolvedXcworkspaceName())

        // 1. mkdir Package
        try (Path.cwd / "Package").mkdir()


        // 1. mkdir App
        try (Path.cwd / "App").mkdir()

        // 1. cd Package
        fs.changeCurrentDirectoryPath((Path.cwd / "Package").string)

        // 1. swift package init --type library
        _ = try Shell.shared.run(arguments: ["swift", "package", "init", "--type", "library"])

        // 1. rm README.md
        try fs.removeItemIfExists(at: (Path.cwd / "README.md").url)

        var rewriter = try ManifestRewriter(packagePath: Path.cwd.absolutePath())
        try rewriter.addTargets(names: options.moduleNames)
        try rewriter.write(to: (Path.cwd / ManifestRewriter.fileName).absolutePath())

        for moduleName in options.moduleNames {
            try generateModuleSampleFile(name: moduleName, rootDirectory: Path.cwd / "Sources")
        }


        // 1. cd ../..
        fs.changeCurrentDirectoryPath(options.destinationDirectory.string)

        // 1. \(options.xcworkspaceName).xcworkspace/contents.xcworkspacedata ?????????
        // 1. \(options.xcworkspaceName).xcworkspace/contents.xcworkspacedata ??? xml ??????????????????
        var workspace = Xcworkspace()
        let location = options.resolvedXcworkspaceName() + "/Package"
        workspace.append(FileReference(location: FilePath(location)))
        let workspacedataPath = Path("\(xcworkspacePah)/contents.xcworkspacedata")!
        try workspace.write(to: workspacedataPath.url)
    }

    func generateModuleSampleFile(name: String, rootDirectory: Path) throws {
        let moduleDir: Path = rootDirectory / name
        try moduleDir.mkdir(.p)
        let content = """
            public struct \(name) {
                public private(set) var text = "Hello, World!"

                public init() {
                }
            }
            """

        try content.write(to: moduleDir / "\(name).swift", atomically: true)
    }
}
