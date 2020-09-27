//
//  RemoteSurveyLoader.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public class RemoteSurveyLoader: SurveyLoader {
  private let httpClient: HTTPClient
  private let url: URL
  private let userTokenType: String
  private let userAccessToken: String
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
    case invalidJSON
  }
  
  public typealias Result = SurveyLoaderResult
  
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
                   userAccessToken: userAccessToken) { [weak self] result in
                    guard self != nil else { return }
                    switch result {
                    case .failure:
                      completion(.failure(Error.connectivity))
                    case let .success(data, response):
                      do {
                        let items = try RemoteSurveyMapper.map(data, response)
                        completion(.success(items))
                      } catch {
                        completion(.failure(error))
                      }
                    }
    }
  }
}


