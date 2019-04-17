//
//  Network.swift
//  GAIA
//
//  Created by Javier on 1/31/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

import UIKit

final class Network {

    static func performRESTRequest<T: Codable>(_ request: RESTRequest, completion: @escaping ((Result<T, Error>) -> Void)) {
        do {
            let urlRequest = try request.toRequest()
            ThreadUtils.runOnMainThread {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            DispatchQueue.global(qos: .userInitiated).async {
                let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, _, error) in
                    ThreadUtils.runOnMainThread {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    guard error == nil else {
                        if let error = error {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        completion(.failure(NetworkError.noDataInResponse))
                        return
                    }
                    let jsonDecoder = JSONDecoder()
                    do {
                        let result = try jsonDecoder.decode(T.self, from: data)
                        completion(.success(result))
                    } catch let error {
                        completion(.failure(error))
                    }
                })
                task.resume()
            }

        } catch let error {
            completion(.failure(error))
        }
    }
}

enum NetworkError: Error {
    case noDataInResponse
    case inconvertibleDataToString
}
