//
//  RemoteSurveyLoader.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public class RemoteSurveyLoader {
  private let httpClient: HTTPClient
  private let url: URL
  private let userTokenType: String
  private let userAccessToken: String
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public enum Result: Equatable {
    case success([SurveyItem])
    case failure(Error)
  }
  
  public init(httpClient: HTTPClient,
              url: URL,
              userTokenType: String,
              userAccessToken: String) {
    self.httpClient = httpClient
    self.url = url
    self.userTokenType = userTokenType
    self.userAccessToken = userAccessToken
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    httpClient.get(from: url,
                   userTokenType: userTokenType,
                   userAccessToken: userAccessToken) { result in
                    switch result {
                    case .failure:
                      completion(.failure(.connectivity))
                    case let .success(data, _):
                      if let _ = try? JSONSerialization.jsonObject(with: data) {
                        completion(.success([]))
                      } else {
                        completion(.failure(.invalidData))
                      }
                    }
    }
  }
}


