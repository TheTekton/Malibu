import Foundation

open class Mock {

  open var request: Requestable
  open var response: HTTPURLResponse?
  open var data: Data?
  open var error: Error?

  // MARK: - Initialization

  public init(request: Requestable, response: HTTPURLResponse?, data: Data?, error: Error? = nil) {
    self.request = request
    self.data = data
    self.response = response
    self.error = error
  }

  public convenience init(request: Requestable, fileName: String, bundle: Bundle = Bundle.main) {
    let fileURL = URL(string: fileName)
    let resource = fileURL?.deletingPathExtension().absoluteString
    let filePath = bundle.path(forResource: resource, ofType: fileURL?.pathExtension)
    let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
    let response = HTTPURLResponse(url: fileURL!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)

    response?.setValue("application/json; charset=utf-8", forKey: "MIMEType")

    self.init(request: request, response: response, data: data, error: nil)
  }

  public convenience init(request: Requestable, JSON: [String: AnyObject]) {
    var JSONData: Data?

    do {
      JSONData = try JSONSerialization.data(withJSONObject: JSON, options: JSONSerialization.WritingOptions())
    } catch {}

    guard let URL = URL(string: "mock://JSON"), let data = JSONData,
      let response = HTTPURLResponse(url: URL, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)
      else {
        self.init(request: request, response: nil, data: nil, error: MalibuError.noResponseReceived)
        return
    }

    response.setValue("application/json; charset=utf-8", forKey: "MIMEType")

    self.init(request: request, response: response, data: data, error: nil)
  }
}
