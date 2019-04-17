//
//  RESTRequest.swift
//  GAIA
//
//  Created by Javier on 2/8/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String: String]

protocol RESTRequest {
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: HTTPHeaders? { get }
    var baseURL: URL? { get }
    var timeout: TimeInterval { get }
    var parameters: Codable? { get }
}

extension RESTRequest {
    var headers: HTTPHeaders? { return .none }
    var timeout: TimeInterval { return 15 }

    var baseURL: URL? {
        #if DEBUG
            return URL(string: "https://api.sandbox.paypal.com")
        #else
            return URL(string: "https://api.paypal.com")
        #endif
    }

    func toRequest() throws -> URLRequest {
        guard var url = baseURL?.appendingPathComponent(path) else {
            throw RequestError.invalidBaseURL
        }
        if path.contains("?"),
            let base = baseURL?.absoluteString,
            let urlWithoutScape = URL(string: base + path) {
            url = urlWithoutScape
        }
        var defaultHeaders = HTTPHeaders()
        defaultHeaders["Content-Type"] = "application/json"

        if let additionalHeaders = headers {
            for (key, value) in additionalHeaders {
                defaultHeaders[key] = value
            }
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = defaultHeaders
        urlRequest.httpMethod = method.rawValue.uppercased()
        urlRequest.httpBody = try parameters?.toJSONData()
        return urlRequest
    }
}

extension Encodable {
    public func toJSONData() throws -> Data {
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(self)
        return data
    }
}

enum RequestError: Error {
    case invalidBaseURL
}
