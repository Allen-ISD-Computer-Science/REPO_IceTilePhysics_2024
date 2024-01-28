import Foundation
import LevelGeneration

class LevelFileManager: Writable {
    let fileManager = FileManager.default
    static let shared = LevelFileManager()

    private init() {}

    func readLVL(filePath: String) -> String? {
        do {
            let lvlString = try String(contentsOf: URL(fileURLWithPath: filePath))
            return lvlString
        } catch {
            print("Error when reading file \(filePath): \(error)")
            return nil
        }
    }

    func encodeLVL(from data: Encodable) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            let lvlData = try encoder.encode(data)
            if let lvlString = String(data: lvlData, encoding: .utf8) {
                return lvlString
            }
        } catch {
            print("Failed to encode dragons: \(error.localizedDescription)")            
        }
        return nil        
    }

    func decodeLVL<T: Codable>(lvlString: String) -> T? {
        let decoder = JSONDecoder()

        guard let lvlData = lvlString.data(using: .utf8) else {
            print("Failed to convert lvlString to Data")
            return nil
        }

        do {
            let data = try decoder.decode(T.self, from: lvlData)
            return data
        }  catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found: \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found: \(context.debugDescription)")
        } catch {
            print("Failed to decode: \(error.localizedDescription)")
        }

        return nil
    }

    func initializeLevel(from filePath: String) -> Level? {
        if let lvlString = readLVL(filePath: filePath),
           let level: Level = decodeLVL(lvlString: lvlString) {
            return level
        }
        return nil
    }
}
