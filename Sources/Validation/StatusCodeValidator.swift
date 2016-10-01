import Foundation

public struct StatusCodeValidator<T: Sequence>: Validating where T.Iterator.Element == Int {

  public var statusCodes: T

  // MARK: - Initialization

  public init(statusCodes: T) {
    self.statusCodes = statusCodes
  }

  // MARK: - Validation

  public func validate(_ result: Wave) throws {
    guard statusCodes.contains(result.response.statusCode) else {
      throw MalibuError.unacceptableStatusCode(result.response.statusCode)
    }
  }
}
