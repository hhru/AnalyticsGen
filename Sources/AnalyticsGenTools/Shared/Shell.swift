import Foundation

@discardableResult
public func shell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil

    Log.debug("shell(\(command))")

    try task.run()
    task.waitUntilExit()

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
