import Foundation
import When

public enum Mode {
    case Regular, Background, Partial, Fake
}

// MARK: - Helpers

var networkings = [String: Networking]()

// MARK: - Vars

public var mode: Mode = .Regular
public var backfootSurfer = Networking()
public var parameterEncoders = [ContentType: ParameterEncoding]()
public let logger = Logger()

let boundary = String(format: "Malibu%08x%08x", arc4random(), arc4random())

// MARK: - Networkings

public func register(name: String, networking: Networking) {
    networkings[name] = networking
}

public func unregister(name: String) -> Bool {
    return networkings.removeValueForKey(name) != nil
}

public func networking(name: String) -> Networking {
    return networkings[name] ?? backfootSurfer
}

// MARK: - Mocks

public func register(mock mock: Mock) {
    backfootSurfer.register(mock: mock)
}

// MARK: - Requests

public func GET(request: GETRequestable) -> Ride {
    return backfootSurfer.GET(request)
}

public func GET(request: GETRequestable, backgroundTask: (session: NSURLSession, URLRequest: NSURLRequest, taskRide: Ride) -> TaskRunning) -> Ride {
    return backfootSurfer.GET(request, backgroundTask: backgroundTask)
}

public func POST(request: POSTRequestable) -> Ride {
    return backfootSurfer.POST(request)
}

public func POST(request: POSTRequestable, backgroundTask: (session: NSURLSession, URLRequest: NSURLRequest, taskRide: Ride) -> TaskRunning) -> Ride {
    return backfootSurfer.POST(request, backgroundTask: backgroundTask)
}

public func PUT(request: PUTRequestable) -> Ride {
    return backfootSurfer.PUT(request)
}

public func PATCH(request: PATCHRequestable) -> Ride {
    return backfootSurfer.PATCH(request)
}

public func DELETE(request: DELETERequestable) -> Ride {
    return backfootSurfer.DELETE(request)
}

public func HEAD(request: HEADRequestable) -> Ride {
    return backfootSurfer.HEAD(request)
}
