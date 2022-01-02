import Foundation
import Dispatch
import ArgumentParser
import Core

Shell.shared.monitoringSignals()

let queue = DispatchQueue(label: "command_main", qos: .default)
queue.async {
    RootCommand.main()
}

dispatchMain()
