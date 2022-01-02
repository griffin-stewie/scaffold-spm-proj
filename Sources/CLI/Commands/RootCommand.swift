import Foundation
import ArgumentParser

struct RootCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "scaffold-spm-proj",
        abstract: "ABSTRUCTION HERE",
        discussion: "DISCUSSION HERE",
        version: "0.1.0",
        subcommands: [ScaffoldCommand.self]
    )
}
