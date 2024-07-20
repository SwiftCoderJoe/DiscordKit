import Foundation

extension String {
    var jsonEncoded: String {
        do {
            return String(data: try JSONEncoder().encode(self), encoding: .utf8)!
        } catch {
            fatalError("Could not encode a String as JSON.")
        }
    }
}