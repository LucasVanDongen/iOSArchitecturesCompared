//
//  Request.swift
//
//  Created by Lucas van Dongen on 5/19/17.
//  Copyright © 2017 Lucas van Dongen. All rights reserved.
//

import UIKit

public enum RequestType: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

public enum RequestInitError: Error {
    case noBodyParametersAllowedForGet
    case getParametersOnlyThroughURL
    case resultingUrlStringWasNotAValidUrl
    case authenticatedRequestWithoutSession
}

public class Request: NSMutableURLRequest {

    public init(with path: String,
                method: RequestType,
                bodyParameters: [String: Any]? = nil,
                urlParameters: [String: Any]? = nil,
                headers: [String: String]? = nil) throws {

        guard !(method == .get && bodyParameters != nil) else {
            throw RequestInitError.noBodyParametersAllowedForGet
        }

        guard !path.contains("?") else {
            throw RequestInitError.getParametersOnlyThroughURL
        }

        let urlParameterString: String
        switch urlParameters {
        case .none:
            urlParameterString = ""
        case .some(let urlParameters):
            let parameterString = urlParameters.map({ (key: String, value: Any) -> String in
                ParameterMapper.map(key: key, value: value)
            }).joined(separator: "&")

            urlParameterString = "?\(parameterString)"
        }

        assertionFailure("Didn't set up URLs yet")
        let urlString = "\(path)\(urlParameterString)" //"\(Conf.urls.playerAPIBaseURL)\(path)\(urlParameterString)"
        guard let url = URL(string: urlString) else {
            throw RequestInitError.resultingUrlStringWasNotAValidUrl
        }

        super.init(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 100000)

        httpMethod = method.rawValue

        if let bodyParameters = bodyParameters {
            let bodyString: String = bodyParameters.map({ (key: String, value: Any) -> String in
                ParameterMapper.map(key: key, value: value)
            }).joined(separator: "&")
            if let data = bodyString.data(using: .utf8) {
                httpBody = data
            }
        }

        if let headers = headers {
            headers.forEach { header in
                addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
