import URI
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Response {
    enum ConversionError: Error {
        case invalidResponseType
        case missingURL
    }

    convenience init(urlResponse: URLResponse?, data: Data?) throws {
        guard let httpResponse = urlResponse as? HTTPURLResponse else { throw ConversionError.invalidResponseType }

        let body = data?.makeBytes() ?? []
        var headers: [HeaderKey: String] = [:]
        httpResponse.allHeaderFields.forEach { key, value in
            headers["\(key)"] = "\(value)"
        }

        let status = Status(statusCode: httpResponse.statusCode)
        
        self.init(status: status, headers: headers, body: Body(body))
    }
}
