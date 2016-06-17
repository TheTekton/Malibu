import Foundation
import When

public protocol TaskRunning: class {
  var URLRequest: NSURLRequest { get }
  var ride: Ride { get }

  func run()
}

extension TaskRunning {

  func process(data: NSData?, response: NSURLResponse?, error: ErrorType?) {
    if let error = error {
      ride.reject(error)
      return
    }

    guard let response = response as? NSHTTPURLResponse else {
      ride.reject(Error.NoResponseReceived)
      return
    }

    guard let data = data else {
      ride.reject(Error.NoDataInResponse)
      return
    }

    let result = Wave(data: data, request: URLRequest, response: response)
    ride.resolve(result)
  }
}
