import Foundation

struct Utils {

  // MARK: - Storage

  static let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
    .userDomainMask, true).first!

  static var storageDirectory: String = {
    let directory = "\(documentDirectory)/Malibu"

    do {
      try FileManager.default.createDirectory(atPath: directory,
        withIntermediateDirectories: true,
        attributes: nil)
    } catch {
      NSLog("Malibu: Error in creation of local storage directory at path: \(directory)")
    }

    return directory
  }()

  static func filePath(_ name: String) -> String {
    return "\(Utils.storageDirectory)/\(name)"
  }
}
