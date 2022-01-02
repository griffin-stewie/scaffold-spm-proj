import Foundation
import ArgumentParser
import Path

struct ScaffoldCommandOptions: ParsableArguments {

    @Option(name: [.customLong("output-dir")], help: ArgumentHelp("where to generate", valueName: "destination_dir"))
    var destinationDirectory: Path = Path.cwd/"."

    @Option()
    var repositoryName: String

    @Option()
    var xcworkspaceName: String?

    @Option()
    var xcodeProjectName: String?

    @Option()
    var moduleNames: [String] = []
}

extension ScaffoldCommandOptions {
    func resolvedXcworkspaceName() -> String {
        guard let xcworkspaceName = xcworkspaceName else {
            return repositoryName
        }

        return xcworkspaceName
    }

    func resolvedXcodeProjectName() -> String {
        guard let xcodeProjectName = xcodeProjectName else {
            return repositoryName
        }

        return xcodeProjectName
    }
}

/*
 repository name
 xcworkspace's name
 xcodeproj's name
 module names

 */