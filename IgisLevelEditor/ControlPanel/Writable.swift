import Foundation

protocol Writable {
    var fileManager: FileManager { get }
    func write(path: String, content: String) -> String
}

extension Writable {
    func write(path: String, content: String) -> String {
        let filePath = URL(fileURLWithPath: path)

        // Check if the directory of the specified file path exists, if not, create it
        let directory = filePath.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return "Error creating directory: \(error)"
            }
        }

        // Save the specified string to the specified file path
        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
            return "File saved successfully at \(path)"
        } catch {
            return "Error writing to file: \(error)"
        }
    }
}
