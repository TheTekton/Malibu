import Foundation

extension String.Index{
    func successor(in string:String)->String.Index{
        return string.index(after: self)
    }
    
    func predecessor(in string:String)->String.Index{
        return string.index(before: self)
    }
    
    func advance(_ offset:Int, `for` string:String)->String.Index{
        return string.index(self, offsetBy: offset)
    }
}

public struct QueryBuilder {

  public typealias Component = (String, String)

  let escapingCharacters = ":#[]@!$&'()*+,;="

  public init() {}

  public func buildQuery(_ parameters: [String: AnyObject]) -> String {
    return buildComponents(parameters: parameters).map({ "\($0)=\($1)" }).joined(separator: "&")
  }

  public func buildComponents(parameters: [String: AnyObject]) -> [Component] {
    var components: [Component] = []

    parameters.forEach { key, value in
      components += buildComponents(key: key, value: value)
    }

    return components
  }

  public func buildComponents(key: String, value: AnyObject) -> [Component] {
    var components: [Component] = []

    if let dictionary = value as? [String: AnyObject] {
      dictionary.forEach { nestedKey, value in
        components += buildComponents(key: "\(key)[\(nestedKey)]", value: value)
      }
    } else if let array = value as? [AnyObject] {
      array.forEach { value in
        components += buildComponents(key: "\(key)[]", value: value)
      }
    } else {
      components.append((escape(key), escape("\(value)")))
    }

    return components
  }

  public func escape(_ string: String) -> String {
    let allowedCharacters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    allowedCharacters.removeCharacters(in: escapingCharacters)

    var escapedString = ""

    if #available(iOS 8.3, *) {
      escapedString = string.addingPercentEncoding(withAllowedCharacters: allowedCharacters as CharacterSet) ?? string
    } else {
      var index = string.startIndex

      while index != string.endIndex {
//        let endIndex = index.advancedBy(50, limit: string.endIndex)
//        let endIndex = <#T##Collection corresponding to `index`##Collection#>.index(index, offsetBy: 50, limitedBy: string.endIndex)
        let endIndex = index.successor(in: string)
        let range = Range(index..<endIndex)
        let substring = string.substring(with: range)

        index = endIndex
        escapedString += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacters as CharacterSet)
          ?? substring
      }
    }

    return escapedString
  }
}
