//
//  GolloPromosService.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation
import GolloNetWorking
import RxRelay
import RxSwift

typealias ResultCallback<Value> = (Result<Value, ParseServerError>) -> Void

enum ParseServerError: LocalizedError {
    case decoding
    case server(code: Int, message: String)
}

extension ParseServerError {
    public var errorDescription: String? {
        switch self {
        case .decoding:
            return ""
        case .server(code: let errorCode, message: let errorMessage):
            return errorMessage.isEmpty ? "error de servidor desconocido, código \(errorCode)" : errorMessage
        }
    }
}

protocol APIRequest: Encodable {
    associatedtype Response: Decodable

    var resourceName: String { get }
    var dictionary: [String: Any] { get }
}

class GolloService {
    let service = GolloNetworking()

    func callWebService<T: APIRequest>(_ request: T,
                                       completion: @escaping ResultCallback<T.Response>) {
        let endpoint = self.endpoint(for: request)
        let parameters = request.dictionary
        log.debug(parameters)
        let jsonPretty = String(data: try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted), encoding: .utf8 )!
        log.debug("Endpoint: \(endpoint) \(jsonPretty)")

        service.invokeService(for: endpoint, method: .post, with: parameters, "") { data, error in
            if let error = error {
                log.debug("Error: \(error)")
                completion(.failure(.server(code: 0, message: error)))
            }
            if let object = self.parseResult(of: T.Response.self, data: data) {
                completion(.success(object))
                log.debug("Response: \(object)")
            } else {
                completion(.failure(.server(code: 0, message: "Unknown error")))
                log.debug("Error: Unknown error")
            }
        }
    }
    
    func callWebServiceGollo<T: APIRequest>(_ request: T,
                                       completion: @escaping ResultCallback<T.Response>) {
        let endpoint = self.endpoint(for: request)
        let parameters = request.dictionary
        log.debug(parameters)
        let jsonPretty = String(data: try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted), encoding: .utf8 )!
        log.debug("Endpoint: \(endpoint) \(jsonPretty)")

        service.invokeService(for: endpoint, method: .post, with: parameters, "") { data, error in
            if let error = error {
                log.debug("Error: \(error)")
                completion(.failure(.server(code: 0, message: error)))
            }
            if let object = self.parseResultGollo(of: T.Response.self, data: data) {
                completion(.success(object))
                log.debug("Response: \(object)")
            } else {
                completion(.failure(.server(code: 0, message: "Unknown error")))
                log.debug("Error: Unknown error")
            }
        }
    }

    func callWebServiceGollo<T: APIRequest>(_ request: T,
                                            completion: @escaping ResultCallback<T.Response>) {
        let endpoint = self.endpoint(for: request)
        let parameters = request.dictionary
        log.debug(parameters)
        let jsonPretty = String(data: try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted), encoding: .utf8 )!
        log.debug("Endpoint: \(endpoint) \(jsonPretty)")

        service.invokeService(for: endpoint, method: .post, with: parameters, "") { data, error in
            if let error = error {
                log.debug("Error: \(error)")
                completion(.failure(.server(code: 0, message: error)))
            }
            if let object = self.parseResultGollo(of: T.Response.self, data: data) {
                completion(.success(object))
                log.debug("Response: \(object)")
            } else {
                completion(.failure(.server(code: 0, message: "Unknown error")))
                log.debug("Error: Unknown error")
            }
        }
    }

    fileprivate func parseResult<T: Decodable>(of type: T.Type = T.self, data: Data?) -> T? {
        guard let data = data else {
            return nil
        }
        log.debug(data.prettyPrintedJSONString)
        do {
            let baseResponse = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
            guard let status = baseResponse.status else { return nil }
            if status {
                return baseResponse.data
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    fileprivate func parseResultGollo<T: Decodable>(of type: T.Type = T.self, data: Data?) -> T? {
        guard let data = data else {
            return nil
        }
        log.debug(data.prettyPrintedJSONString)
        do {
            let baseResponse = try JSONDecoder().decode(BaseResponseGollo<T>.self, from: data)
            guard let status = baseResponse.resultado?.estado else { return nil }
            if status == "true" {
                return baseResponse.respuesta
            } else {
                return nil
            }
        } catch let error as NSError {
            log.debug("parseResultGollo: " + error.localizedDescription)
            return nil
        }
    }

    fileprivate func parseResultGollo<T: Decodable>(of type: T.Type = T.self, data: Data?) -> T? {
        guard let data = data else {
            return nil
        }
        log.debug(data.prettyPrintedJSONString)
        do {
            let baseResponse = try JSONDecoder().decode(BaseResponseGollo<T>.self, from: data)
            guard let status = baseResponse.resultado?.estado else { return nil }
            if status == "true" {
                return baseResponse.respuesta
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    private func endpoint<T: APIRequest>(for request: T) -> String {
        return "\(APDLGT.GURLAPI)\(request.resourceName)"
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

