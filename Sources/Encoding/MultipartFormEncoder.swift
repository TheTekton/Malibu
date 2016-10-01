import Foundation

struct MultipartFormEncoder: ParameterEncoding {

  // MARK: - ParameterEncoding

  func encode(_ parameters: [String: AnyObject]) throws -> Data? {
    let string = buildMultipartString(parameters, boundary: boundary)

    guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
      throw MalibuError.invalidParameter
    }

    return data
  }

  // MARK: - Helpers

  func buildMultipartString(_ parameters: [String: AnyObject], boundary: String) -> String {
    var string = ""
    let components = QueryBuilder().buildComponents(parameters: parameters)

    for (key, value) in components {
      string += "--\(boundary)\r\n"
      string += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
      string += "\(value)\r\n"
    }

    string += "--\(boundary)--\r\n"

    return string
  }
}
