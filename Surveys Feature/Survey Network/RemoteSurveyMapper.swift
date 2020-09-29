//
//  RemoteSurveyMapper.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/27/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

class RemoteSurveyMapper {
  
  struct Root: Decodable {
    let remoteData: [RemoteSurvey]
    
    var surveys: [Survey] {
      remoteData.map(\.survey)
    }
    
    enum CodingKeys: String, CodingKey {
      case remoteData = "data"
    }
  }
  
  static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Survey] {
    guard response.statusCode == RemoteSurvey.successfulStatusCode else {
      if response.statusCode == RemoteSurvey.unauthorizedStatusCode {
        throw RemoteSurveyLoader.Error.unauthorized
      }
      throw RemoteSurveyLoader.Error.invalidData
    }
    
    guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
       throw RemoteSurveyLoader.Error.invalidJSON
    }
    
    return root.surveys
  }
}
