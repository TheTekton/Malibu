import Foundation
import When

public protocol TaskRunning: class {
  var URLRequest: Foundation.URLRequest { get }
  var ride: Ride { get }

  func run()
}

extension TaskRunning {

  func process(_ data: Data?, response: URLResponse?, error: Error?) {
    if let error = error {
      ride.reject(error)
      return
    }

    guard let response = response as? HTTPURLResponse else {
      ride.reject(MalibuError.noResponseReceived)
      return
    }

    guard let data = data else {
      ride.reject(MalibuError.noDataInResponse)
      return
    }

    let result = Wave(data: data, request: URLRequest, response: response)
    ride.resolve(result)
  }
}
