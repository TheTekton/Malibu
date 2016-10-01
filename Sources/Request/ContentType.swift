import Foundation

public enum ContentType {
    case query
    case formURLEncoded
    case json
    case multipartFormData
    case custom(String)
    
    public var header: String? {
        let string: String?
        
        switch self {
        case .query:
            string = nil
        case .json:
            string = "application/json"
        case .formURLEncoded:
            string = "application/x-www-form-urlencoded"
        case .multipartFormData:
            string = "multipart/form-data; boundary=\(boundary)"
        case .custom(let value):
            string = value
        }
        
        return string
    }
    
    public var encoder: ParameterEncoding? {
        var encoder: ParameterEncoding?
        
        switch self {
        case .json:
            encoder = JSONEncoder()
        case .formURLEncoded:
            encoder = FormURLEncoder()
        case .multipartFormData():
            encoder = MultipartFormEncoder()
        default:
            break
        }
        
        return encoder
    }
}

// MARK: - Hashable

extension ContentType: Hashable {
    
    public var hashValue: Int {
        let string = header ?? "query"
        return string.hashValue
    }
}

// MARK: - Equatable

public func ==(lhs: ContentType, rhs: ContentType) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
