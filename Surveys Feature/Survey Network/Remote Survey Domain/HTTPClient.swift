//
//  HTTPClient.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public protocol HTTPClient {
  
  typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func get(from url: URL,
           userTokenType: String,
           userAccessToken: String,
           completion: @escaping (Result) -> Void)
}
