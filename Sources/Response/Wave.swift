import Foundation
import When

open class Wave: Equatable {

  open let data: Data
  open let request: URLRequest
  open let response: HTTPURLResponse

  public init(data: Data, request: URLRequest, response: HTTPURLResponse) {
    self.data = data
    self.request = request
    self.response = response
  }
}

// MARK: - Equatable

public func ==(lhs: Wave, rhs: Wave) -> Bool {
  return lhs.data == rhs.data
    && lhs.request == rhs.request
    && lhs.response == rhs.response
}
