import Foundation
import When

@objc(Networking)
public class Networking: NSObject {
    
    enum SessionTaskKind {
        case Data, Upload, Download
    }
    
    public var additionalHeaders: (() -> [String: String])?
    public var beforeEach: (Requestable -> Requestable)?
    public var preProcessRequest: (NSMutableURLRequest -> Void)?
    
    var baseURLString: URLStringConvertible?
    var sessionConfiguration: SessionConfiguration
    var customHeaders = [String: String]()
    var mocks = [String: Mock]()
    
    weak var sessionDelegate: NSURLSessionDelegate?
    
    lazy var session: NSURLSession = {
        return NSURLSession(
            configuration: self.sessionConfiguration.value,
            delegate: self.sessionDelegate ?? self,
            delegateQueue: nil)
    }()
    
    var requestHeaders: [String: String] {
        var headers = customHeaders
        
        headers["Accept-Language"] = Header.acceptLanguage
        
        let extraHeaders = additionalHeaders?() ?? [:]
        
        extraHeaders.forEach { key, value in
            headers[key] = value
        }
        
        return headers
    }
    
    // MARK: - Initialization
    
    public init(baseURLString: URLStringConvertible? = nil,
                sessionConfiguration: SessionConfiguration = .Default,
                sessionDelegate: NSURLSessionDelegate? = nil) {
        self.baseURLString = baseURLString
        self.sessionConfiguration = sessionConfiguration
        self.sessionDelegate = sessionDelegate
    }
    
    // Mark: - ObjC Helpers
    public func setInitBaseURLString(url: String) {
        self.baseURLString = url
    }
    
    public func setInitSessionConfiguration(sessionConfiguration: NSURLSessionConfiguration) {
        self.sessionConfiguration = SessionConfigurationBridge.Custom(sessionConfiguration)
    }
    
    public func setInitSessionDelegate(sessionDelegate: NSURLSessionDelegate) {
        self.sessionDelegate = sessionDelegate
    }
    
    // MARK: - Networking
    
    func execute(request: Requestable, backgroundTask: ((session: NSURLSession, URLRequest: NSURLRequest, taskRide: Ride) -> TaskRunning)?) -> Ride {
        let ride = Ride()
        let URLRequest: NSMutableURLRequest
        
        do {
            let request = beforeEach?(request) ?? request
            URLRequest = try request.toURLRequest(baseURLString, additionalHeaders: requestHeaders)
        } catch {
            ride.reject(error)
            return ride
        }
        
        preProcessRequest?(URLRequest)
        
        let task: TaskRunning
        
        switch Malibu.mode {
        case .Regular:
            task = SessionDataTask(session: session, URLRequest: URLRequest, ride: ride)
        case .Background:
            task = backgroundTask!(session: session, URLRequest: URLRequest, taskRide: ride)
        case .Partial:
            if let mock = prepareMock(request) {
                task = MockDataTask(mock: mock, URLRequest: URLRequest, ride: ride)
            } else {
                task = SessionDataTask(session: session, URLRequest: URLRequest, ride: ride)
            }
        case .Fake:
            guard let mock = prepareMock(request) else {
                ride.reject(Error.NoMockProvided)
                return ride
            }
            
            task = MockDataTask(mock: mock, URLRequest: URLRequest, ride: ride)
        }
        
        let etagPromise = ride.then { result -> Wave in
            self.saveEtag(request, response: result.response)
            return result
        }
        
        let nextRide = Ride()
        
        etagPromise
            .done({ value in
                if logger.enabled {
                    logger.requestLogger.init(level: logger.level).logRequest(request, URLRequest: value.request)
                    logger.responseLogger.init(level: logger.level).logResponse(value.response)
                }
                nextRide.resolve(value)
            })
            .fail({ error in
                if logger.enabled {
                    logger.errorLogger.init(level: logger.level).logError(error)
                }
                
                nextRide.reject(error)
            })
        
        task.run()
        
        return nextRide
    }
    
    // MARK: - Authentication
    
    public func authenticate(username username: String, password: String) {
        guard let header = Header.authentication(username: username, password: password) else {
            return
        }
        
        customHeaders["Authorization"] = header
    }
    
    public func authenticate(authorizationHeader authorizationHeader: String) {
        customHeaders["Authorization"] = authorizationHeader
    }
    
    public func authenticate(bearerToken bearerToken: String) {
        customHeaders["Authorization"] = "Bearer \(bearerToken)"
    }
    
    // MARK: - Mocks
    
    public func register(mock mock: Mock) {
        mocks[mock.request.key] = mock
    }
    
    func prepareMock(request: Requestable) -> Mock? {
        guard let mock = mocks[request.key] else { return nil }
        
        mock.request = beforeEach?(mock.request) ?? mock.request
        
        return mock
    }
    
    // MARK: - Helpers
    
    func saveEtag(request: Requestable, response: NSHTTPURLResponse) {
        guard let etag = response.allHeaderFields["ETag"] as? String else {
            return
        }
        
        let prefix = baseURLString?.URLString ?? ""
        
        ETagStorage().add(etag, forKey: request.etagKey(prefix))
    }
}

// MARK: - Requests

public extension Networking {
    
    public func GET(request: GETRequestable) -> Ride {
        return execute(request, backgroundTask: nil)
    }
    
    public func POST(request: POSTRequestable, backgroundTask: ((session: NSURLSession, URLRequest: NSURLRequest, taskRide: Ride) -> TaskRunning)?) -> Ride {
        return execute(request, backgroundTask: backgroundTask)
    }
    
    public func PUT(request: PUTRequestable) -> Ride {
        return execute(request, backgroundTask: nil)
    }
    
    public func PATCH(request: PATCHRequestable) -> Ride {
        return execute(request, backgroundTask: nil)
    }
    
    public func DELETE(request: DELETERequestable) -> Ride {
        return execute(request, backgroundTask: nil)
    }
    
    public func HEAD(request: HEADRequestable) -> Ride {
        return execute(request, backgroundTask: nil)
    }
}

// MARK: - NSURLSessionDelegate

extension Networking: NSURLSessionDelegate {
    
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        guard let baseURLString = baseURLString,
            baseURL = NSURL(string: baseURLString.URLString),
            serverTrust = challenge.protectionSpace.serverTrust
            else { return }
        
        if challenge.protectionSpace.host == baseURL.host {
            completionHandler(
                NSURLSessionAuthChallengeDisposition.UseCredential,
                NSURLCredential(forTrust: serverTrust))
        }
    }
}
