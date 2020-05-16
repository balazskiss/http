import Transport
import Foundation
import URI
import Core
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// client based on Foundation.URLRequest
/// and Foundation.URLSession
public final class FoundationClient: Client {
    public let scheme: String
    public let hostname: String
    public let port: Transport.Port
    public let session: URLSession

    /// create a new foundation client
    public init(
        scheme: String,
        hostname: String,
        port: Transport.Port,
        session: URLSession = URLSession(configuration: .default)
    ) {
        self.scheme = scheme
        self.hostname = hostname
        self.port = port
        self.session = session
    }

    /// responds to the request using URLResponse
    public func respond(to request: Request) throws -> Response {
        try assertValid(request)
        
        return try Portal.open { portal in
            let foundationRequest = try request.makeFoundationRequest()
            let task = self.session.dataTask(with: foundationRequest) { data, urlResponse, error in
                if let error = error {
                    portal.close(with: error)
                    return
                }
                
                do {
                    let response = try Response(urlResponse: urlResponse, data: data)
                    portal.close(with: response)
                } catch {
                    portal.close(with: error)
                }
            }
            task.resume()
        }
    }
}
