import Foundation

@discardableResult
public func shell(_ command: String, timeout: TimeInterval = 600) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil

    Log.debug("shell(\(command))")

    try task.run()
    
    let finished = task.waitUntilExit(timeout: timeout)
    if !finished {
        task.terminate()
        throw NSError(
            domain: "ShellCommandError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Command timed out after \(timeout) seconds: \(command)"]
        )
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    if task.terminationStatus != 0 {
        throw NSError(
            domain: "ShellCommandError",
            code: Int(task.terminationStatus),
            userInfo: [NSLocalizedDescriptionKey: output]
        )
    }

    return output
}

extension Process {

    func waitUntilExit(timeout: TimeInterval) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var hasFinished = false

        let queue = DispatchQueue.global()
        queue.async {
            self.waitUntilExit()
            hasFinished = true
            semaphore.signal()
        }

        let result = semaphore.wait(timeout: .now() + timeout)
        return result == .success && hasFinished
    }
}
