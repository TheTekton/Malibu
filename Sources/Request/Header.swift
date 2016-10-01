import Foundation

struct Header {

  static let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"

  static var acceptLanguage: String {
    return Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
      let quality = 1.0 - (Double(index) * 0.1)
      return "\(languageCode);q=\(quality)"
      }.joined(separator: ", ")
  }

  static let userAgent: String = {
    var string = "Malibu"

    if let info = Bundle.main.infoDictionary {
      let executable: AnyObject = info[kCFBundleExecutableKey as String] as AnyObject? ?? "Unknown" as AnyObject
      let bundle: AnyObject = info[kCFBundleIdentifierKey as String] as AnyObject? ?? "Unknown" as AnyObject
      let version: AnyObject = info[kCFBundleVersionKey as String] as AnyObject? ?? "Unknown" as AnyObject
      let os: AnyObject = ProcessInfo.processInfo.operatingSystemVersionString as AnyObject? ?? "Unknown" as AnyObject
      let mutableUserAgent = NSMutableString(
        string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
      let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString

      if CFStringTransform(mutableUserAgent, nil, transform, false) {
        string = mutableUserAgent as String
      }
    }

    return string
  }()

  static let defaultHeaders: [String: String] = {
    return [
      "Accept-Encoding": acceptEncoding,
      "User-Agent": userAgent
    ]
  }()

  static func authentication(username: String, password: String) -> String? {
    let credentials = "\(username):\(password)"

    guard let credentialsData = credentials.data(using: String.Encoding.utf8) else {
      return nil
    }

    let base64Credentials = credentialsData.base64EncodedString(options: [])

    return "Basic \(base64Credentials)"
  }
}
