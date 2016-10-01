import Foundation
import When

open class Ride: Promise<Wave> {

  open var task: URLSessionTask?

  public init(task: URLSessionTask? = nil) {
    self.task = task
    super.init()
  }

  open func cancel() {
    task?.cancel()
    task = nil
  }
}
