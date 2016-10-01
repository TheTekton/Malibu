import Foundation

public struct JSONSerializer: Serializing {

  let options: JSONSerialization.ReadingOptions

  public init(options: JSONSerialization.ReadingOptions = .allowFragments) {
    self.options = options
  }

  public func serialize(_ data: Data, response: HTTPURLResponse) throws -> AnyObject {
    if response.statusCode == 204 { return NSNull() }

    guard data.count > 0 else {
      throw MalibuError.noDataInResponse
    }

    do {
      return try JSONSerialization.jsonObject(with: data, options: options) as AnyObject
    } catch {
      throw error
    }
  }
}
