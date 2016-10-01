import Foundation

struct MIMEType {

  static func components(_ string: String) -> (type: String?, subtype: String?) {
    let trimmed = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let splitted = trimmed.substring(to: trimmed.range(of: ";")?.lowerBound ?? trimmed.endIndex)
    let array = splitted.components(separatedBy: "/")

    return (type: array.first, subtype: array.last)
  }

  let type: String
  let subtype: String

  // MARK: - Initialization

  init?(contentType: String) {
    let components = MIMEType.components(contentType)

    guard let type = components.type, let subtype = components.subtype else {
      return nil
    }

    self.type = type
    self.subtype = subtype
  }

  // MARK: - Matches

  func matches(_ MIME: MIMEType) -> Bool {
    var result: Bool

    switch (type, subtype) {
    case (MIME.type, MIME.subtype), (MIME.type, "*"), ("*", MIME.subtype), ("*", "*"):
      result = true
    default:
      result = false
    }

    return result
  }
}
