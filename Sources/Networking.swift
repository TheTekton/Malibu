import Foundation
import When

@objc(Networking)
public class Networking: NSObject {
    
    enum SessionTaskKind {
        case Data, Upload, Download
    }
    
    public var additionalHeaders: (() -> [String: String])?
    public var beforeEach: ((Requestable) -> Requestable)?
    public var preProcessRequest: ((NSMutableURLRequest) -> Void)?
    
    var baseURLString: URLStringConvertible?
    var sessionConfiguration: SessionConfiguration
    var customHeaders = [String: String]()
    var mocks = [String: Mock]()
    
    weak var sessionDelegate: URLSessionDelegate?
    
    public lazy var session: URLSession = {
        return Foundation.URLSession(
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
                sessionConfiguration: SessionConfiguration = .default,
                sessionDelegate: URLSessionDelegate? = nil) {
        self.baseURLString = baseURLString
        self.sessionConfiguration = sessionConfiguration
        self.sessionDelegate = sessionDelegate
    }
    
    // Mark: - ObjC Helpers
    public func setInitBaseURLString(url: String) {
        self.baseURLString = url
    }
    
    public func setInitSessionConfiguration(sessionConfiguration: URLSessionConfiguration) {
        self.sessionConfiguration = SessionConfigurationBridge.Custom(sessionConfiguration)
    }
    
    public func setInitSessionDelegate(sessionDelegate: URLSessionDelegate) {
        self.sessionDelegate = sessionDelegate
    }
    
    // MARK: - Networking
    
    func execute(request: Requestable) -> Ride {
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
        
        var task: TaskRunning? = nil
        
        switch Malibu.mode {
        case .regular:
            task = SessionDataTask(session: session, URLRequest: URLRequest as URLRequest, ride: ride)
        case .background:
            ride.reject(MalibuError.invalidParameter)
        case .partial:
            if let mock = prepareMock(request: request) {
                task = MockDataTask(mock: mock, URLRequest: URLRequest as URLRequest, ride: ride)
            } else {
                task = SessionDataTask(session: session, URLRequest: URLRequest as URLRequest, ride: ride)
            }
        case .fake:
            guard let mock = prepareMock(request: request) else {
                ride.reject(MalibuError.noMockProvided)
                return ride
            }
            
            task = MockDataTask(mock: mock, URLRequest: URLRequest as URLRequest, ride: ride)
        default:
            task = SessionDataTask(session: session, URLRequest: URLRequest as URLRequest, ride: ride)
        }
        
        
        let etagPromise = ride.then { result -> Wave in
            self.saveEtag(request: request, response: result.response)
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
        
        task?.run()
        
        return nextRide
    }
    
    func execute(request: Requestable, backgroundTask: @escaping (_ session: URLSession, _ URLRequest: URLRequest, _ taskRide: Ride) -> TaskRunning) -> Ride {
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
        case .regular:
            task = SessionDataTask(session: session, URLRequest: URLRequest as URLRequest, ride: ride)
        case .background:
            task = backgroundTask(session, URLRequest as URLRequest, ride)
        case .partial:
            if let mock = prepareMock(request: request) {
                task = MockDataTask(mock: mock, URLRequest: URLRequest as URLRequest, ride: ride)
            } else {
                task = SessionDataTask(session: session, URLRequest: URLRequest as URLRequest, ride: ride)
            }
        case .fake:
            guard let mock = prepareMock(request: request) else {
                ride.reject(MalibuError.noMockProvided)
                return ride
            }
            
            task = MockDataTask(mock: mock, URLRequest: URLRequest as URLRequest, ride: ride)
        }
        
        let etagPromise = ride.then { result -> Wave in
            self.saveEtag(request: request, response: result.response)
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
    
    public func authenticate(username: String, password: String) {
        guard let header = Header.authentication(username: username, password: password) else {
            return
        }
        
        customHeaders["Authorization"] = header
    }
    
    public func authenticate(authorizationHeader: String) {
        customHeaders["Authorization"] = authorizationHeader
    }
    
    public func authenticate(bearerToken: String) {
        customHeaders["Authorization"] = "Bearer \(bearerToken)"
    }
    
    // MARK: - Mocks
    
    public func register(mock: Mock) {
        mocks[mock.request.key] = mock
    }
    
    func prepareMock(request: Requestable) -> Mock? {
        guard let mock = mocks[request.key] else { return nil }
        
        mock.request = beforeEach?(mock.request) ?? mock.request
        
        return mock
    }
    
    // MARK: - Helpers
    
    func saveEtag(request: Requestable, response: HTTPURLResponse) {
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
        return execute(request: request)
    }
    
    public func GET(request: GETRequestable, backgroundTask: @escaping (_ session: URLSession, _ URLRequest: URLRequest, _ taskRide: Ride) -> TaskRunning) -> Ride {
        return execute(request: request, backgroundTask: backgroundTask)
    }
    
    public func POST(request: POSTRequestable) -> Ride {
        return execute(request: request)
    }
    
    public func POST(request: POSTRequestable, backgroundTask: @escaping (_ session: URLSession, _ URLRequest: URLRequest, _ taskRide: Ride) -> TaskRunning) -> Ride {
        return execute(request: request, backgroundTask: backgroundTask)
    }
    
    public func PUT(request: PUTRequestable) -> Ride {
        return execute(request: request)
    }
    
    public func PATCH(request: PATCHRequestable) -> Ride {
        return execute(request: request)
    }
    
    public func DELETE(request: DELETERequestable) -> Ride {
        return execute(request: request)
    }
    
    public func HEAD(request: HEADRequestable) -> Ride {
        return execute(request: request)
    }
}

// MARK: - NSURLSessionDelegate

extension Networking: URLSessionDelegate {
    
    public func URLSession(session: URLSession, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, Foundation.URLCredential?) -> Void) {
        guard let baseURLString = baseURLString,
            let baseURL = NSURL(string: baseURLString.URLString),
            let serverTrust = challenge.protectionSpace.serverTrust
            else { return }
        
        if challenge.protectionSpace.host == baseURL.host {
            completionHandler(
                Foundation.URLSession.AuthChallengeDisposition.useCredential,
                URLCredential(trust: serverTrust))
        }
    }
}
