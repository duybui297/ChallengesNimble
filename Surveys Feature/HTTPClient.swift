//
//  HTTPClient.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
  case success(HTTPURLResponse)
  case failure(Error)
}

public protocol HTTPClient {
  func get(from url: URL,
           userTokenType: String,
           userAccessToken: String,
           completion: @escaping (HTTPClientResult) -> Void)
}
