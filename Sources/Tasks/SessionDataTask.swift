import Foundation
import When

class SessionDataTask: TaskRunning {

  var session: URLSession
  var URLRequest: Foundation.URLRequest
  var ride: Ride

  // MARK: - Initialization

  init(session: URLSession, URLRequest: Foundation.URLRequest, ride: Ride) {
    self.session = session
    self.URLRequest = URLRequest
    self.ride = ride
  }

  // MARK: - NetworkTaskRunning

  func run() {
    let task = session.dataTask(with: URLRequest, completionHandler: process)
    task.resume()

    ride.task = task
  }
}
