import Foundation

public enum SessionConfiguration {
    case `default`, ephemeral, background, custom(URLSessionConfiguration)
    
    var value: URLSessionConfiguration {
        var value: URLSessionConfiguration
        
        switch self {
        case .default:
            value = URLSessionConfiguration.default
        case .ephemeral:
            value = URLSessionConfiguration.ephemeral
        case .background:
            value =  URLSessionConfiguration.background(
                withIdentifier: "MalibuBackgroundConfiguration")
        case .custom(let sessionConfiguration):
            value = sessionConfiguration
        }
        
        value.httpAdditionalHeaders = Header.defaultHeaders
        
        return value
    }
}

@objc
class SessionConfigurationBridge: NSObject {
    
    class func Default() -> URLSessionConfiguration {
        return URLSessionConfiguration.default
    }
    
    class func Ephemeral() -> URLSessionConfiguration {
        return URLSessionConfiguration.ephemeral
    }
    
    class func Background() -> URLSessionConfiguration {
        return URLSessionConfiguration.background(
            withIdentifier: "MalibuBackgroundConfiguration")
    }
    
    class func Custom(_ sessionConfiguration: URLSessionConfiguration) -> SessionConfiguration {
        return SessionConfiguration.custom(sessionConfiguration)
    }
}
