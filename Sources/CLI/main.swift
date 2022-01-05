import ArgumentParser
import Core
import Dispatch
import Foundation

Shell.shared.monitoringSignals()

let queue = DispatchQueue(label: "command_main", qos: .default)
queue.async {
    RootCommand.main()
}

dispatchMain()
