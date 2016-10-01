import Foundation

public enum MalibuError: Error {
  case noMockProvided
  case invalidRequestURL
  case missingContentType
  case invalidParameter
  case invalidUploadFilePath
  case noDataInResponse
  case noResponseReceived
  case unacceptableStatusCode(Int)
  case unacceptableContentType(String)
  case jsonArraySerializationFailed
  case jsonDictionarySerializationFailed
  case stringSerializationFailed(UInt)

  public var reason: String {
    var text: String

    switch self {
    case .noMockProvided:
      text = "No mock provided for the current request and method"
    case .invalidRequestURL:
      text = "Invalid request URL"
    case .missingContentType:
      text = "Response content type was missing"
    case .invalidParameter:
      text = "Parameter is not convertible to NSData"
    case .invalidUploadFilePath:
      text = "Invalid upload file path"
    case .noDataInResponse:
      text = "No data in response"
    case .noResponseReceived:
      text = "No response received"
    case .unacceptableStatusCode(let statusCode):
      text = "Response status code \(statusCode) was unacceptable"
    case .unacceptableContentType(let contentType):
      text = "Response content type \(contentType) was unacceptable"
    case .jsonArraySerializationFailed:
      text = "No JSON array in response data"
    case .jsonDictionarySerializationFailed:
      text = "No JSON dictionary in response data"
    case .stringSerializationFailed(let encoding):
      text = "String could not be serialized with encoding: \(encoding)"
    }

    return NSLocalizedString(text, comment: "")
  }
}

// MARK: - Hashable

extension MalibuError: Hashable {

  public var hashValue: Int {
    return reason.hashValue
  }
}

// MARK: - Equatable

public func ==(lhs: MalibuError, rhs: MalibuError) -> Bool {
  return lhs.reason == rhs.reason
}
