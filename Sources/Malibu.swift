import Foundation
import When

public enum Mode {
    case regular, background, partial, fake
}

// MARK: - Helpers

var networkings = [String: Networking]()

// MARK: - Vars

public var mode: Mode = .regular
public var backfootSurfer = Networking()
public var parameterEncoders = [ContentType: ParameterEncoding]()
public let logger = Logger()

let boundary = String(format: "Malibu%08x%08x", arc4random(), arc4random())

// MARK: - Networkings

public func register(_ name: String, networking: Networking) {
    networkings[name] = networking
}

public func unregister(_ name: String) -> Bool {
    return networkings.removeValue(forKey: name) != nil
}

public func networking(_ name: String) -> Networking {
    return networkings[name] ?? backfootSurfer
}

// MARK: - Mocks

public func register(mock: Mock) {
    backfootSurfer.register(mock: mock)
}

// MARK: - Requests

public func GET(_ request: GETRequestable) -> Ride {
    return backfootSurfer.GET(request: request)
}

public func GET(_ request: GETRequestable, backgroundTask: @escaping (_ session: URLSession, _ URLRequest: URLRequest, _ taskRide: Ride) -> TaskRunning) -> Ride {
    return backfootSurfer.GET(request: request, backgroundTask: backgroundTask)
}

public func POST(_ request: POSTRequestable) -> Ride {
    return backfootSurfer.POST(request: request)
}

public func POST(_ request: POSTRequestable, backgroundTask: @escaping (_ session: URLSession, _ URLRequest: URLRequest, _ taskRide: Ride) -> TaskRunning) -> Ride {
    return backfootSurfer.POST(request: request, backgroundTask: backgroundTask)
}

public func PUT(_ request: PUTRequestable) -> Ride {
    return backfootSurfer.PUT(request: request)
}

public func PATCH(_ request: PATCHRequestable) -> Ride {
    return backfootSurfer.PATCH(request: request)
}

public func DELETE(_ request: DELETERequestable) -> Ride {
    return backfootSurfer.DELETE(request: request)
}

public func HEAD(_ request: HEADRequestable) -> Ride {
    return backfootSurfer.HEAD(request: request)
}
