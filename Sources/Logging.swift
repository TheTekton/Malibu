import Foundation

// MARK: - Logger

public enum LogLevel {
  case none, error, info, verbose
}

open class Logger {

  open var level: LogLevel = .none
  open var errorLogger: ErrorLogging.Type = ErrorLogger.self
  open var requestLogger: RequestLogging.Type = RequestLogger.self
  open var responseLogger: ResponseLogging.Type = ResponseLogger.self

  open var enabled: Bool {
    return level != .none
  }
}

public protocol Logging {
  var level: LogLevel { get }
  init(level: LogLevel)
}

// MARK: - Errors

public protocol ErrorLogging: Logging {
  func logError(_ error: Error)
}

public struct ErrorLogger: ErrorLogging {

  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public func logError(_ error: Error) {
    guard level != .none else {
      return
    }

    print("\(error)")
  }
}

// MARK: - Request

public protocol RequestLogging: Logging {
  func logRequest(_ request: Requestable, URLRequest: URLRequest)
}

public struct RequestLogger: RequestLogging {

  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public func logRequest(_ request: Requestable, URLRequest: Foundation.URLRequest) {
    guard let URLString = URLRequest.url?.absoluteString else {
      return
    }

    guard level == .info || level == .verbose else {
      return
    }

    print("🏄 MALIBU: Catching the wave...")
    print("\(request.method.rawValue) \(URLString)")

    guard level == .verbose else {
      return
    }

    if let headers = URLRequest.allHTTPHeaderFields , !headers.isEmpty {
      print("Headers:")
      print(headers)
    }

    if !request.message.parameters.isEmpty && request.contentType != .query {
      print("Parameters:")
      print(request.message.parameters)
    }
  }
}

// MARK: - Response

public protocol ResponseLogging: Logging {
  func logResponse(_ response: HTTPURLResponse)
}

public struct ResponseLogger: ResponseLogging {

  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public  func logResponse(_ response: HTTPURLResponse) {
    guard level == .info || level == .verbose else {
      return
    }

    print("Response: \(response.statusCode)")
  }
}
