//
//  URLSessionHTTPClient.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/28/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
  private let session: URLSession
  
  public struct UnexpectedValuesRepresentation: Error {}
  
  public init(session: URLSession = .shared) {
    self.session = session
  }
  
  public func get(from url: URL,
           userTokenType: String,
           userAccessToken: String,
           completion: @escaping (HTTPClient.Result) -> Void) {
    let urlRequest = makeURLRequestFrom(from: url,
                                        userTokenType: userTokenType,
                                        userAccessToken: userAccessToken)
    session.dataTask(with: urlRequest) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let response = response as? HTTPURLResponse {
        completion(.success((data, response)))
      } else {
        completion(.failure(UnexpectedValuesRepresentation()))
      }
    }.resume()
  }
  
  private func makeURLRequestFrom(from url: URL,
                                  userTokenType: String,
                                  userAccessToken: String) -> URLRequest {
    let authorizationValue = "\(userTokenType) \(userAccessToken)"
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue(authorizationValue, forHTTPHeaderField: "Authorization")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return urlRequest
  }
}
