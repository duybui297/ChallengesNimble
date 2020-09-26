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
  
  public init(httpClient: HTTPClient,
       url: URL,
       userTokenType: String,
       userAccessToken: String) {
    self.httpClient = httpClient
    self.url = url
    self.userTokenType = userTokenType
    self.userAccessToken = userAccessToken
  }
  
  public func load(completion: @escaping (Error) -> Void) {
    httpClient.get(from: url,
                   userTokenType: userTokenType,
                   userAccessToken: userAccessToken) { error, _ in
                    if error != nil {
                      completion(.connectivity)
                    } else {
                      completion(.invalidData)
                    }
    }
  }
}


