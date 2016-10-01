import Foundation
import When

class MockDataTask: TaskRunning {

  let mock: Mock
  let URLRequest: Foundation.URLRequest
  let ride: Ride

  // MARK: - Initialization

  init(mock: Mock, URLRequest: Foundation.URLRequest, ride: Ride) {
    self.mock = mock
    self.URLRequest = URLRequest
    self.ride = ride
  }

  // MARK: - NetworkTaskRunning

  func run() {
    process(mock.data, response: mock.response, error: mock.error)
  }
}
