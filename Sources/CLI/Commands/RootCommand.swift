import ArgumentParser
import Foundation

struct RootCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "scaffold-spm-proj",
        abstract: "Supports to setup the hyper-modularized style by Point-Free using SwiftPM.",
        version: "0.1.0",
        subcommands: [ScaffoldCommand.self]
    )
}
