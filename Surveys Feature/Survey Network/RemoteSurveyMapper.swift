//
//  RemoteSurveyItem.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/27/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

class RemoteSurveyMapper {
  
  struct Root: Decodable {
    let remoteData: [RemoteSurveyItem]
    
    var surveyItems: [SurveyItem] {
      remoteData.map(\.surveyItem)
    }
    
    enum CodingKeys: String, CodingKey {
      case remoteData = "data"
    }
  }
  
  struct RemoteSurveyAttribute: Equatable, Decodable {
    let title: String
    let description: String
    let thankEmailAboveThreshold: String?
    let thankEmailBelowThreshold: String?
    let isActive: Bool
    let coverImageURL: URL
    let createdAt: String
    let activeAt: String
    let inactiveAt: String?
    let surveyType: String
    
    var surveyAttribute: SurveyAttribute {
      SurveyAttribute(title: title,
                      description: description,
                      thankEmailAboveThreshold: thankEmailAboveThreshold,
                      thankEmailBelowThreshold: thankEmailBelowThreshold,
                      isActive: isActive,
                      coverImageURL: coverImageURL,
                      createdAt: createdAt,
                      activeAt: activeAt,
                      inactiveAt: inactiveAt,
                      surveyType: surveyType)
    }
    
    private enum CodingKeys: String, CodingKey {
      case title, description
      case thankEmailAboveThreshold = "thank_email_above_threshold"
      case thankEmailBelowThreshold = "thank_email_below_threshold"
      case isActive = "is_active"
      case coverImageURL = "cover_image_url"
      case createdAt = "created_at"
      case activeAt = "active_at"
      case inactiveAt = "inactive_at"
      case surveyType = "survey_type"
    }
  }

  struct RemoteSurveyItem: Equatable, Decodable {
    let id: String
    let type: String
    let attributes: RemoteSurveyAttribute
    
    static let successfulStatusCode = 200
    static let unauthorizedStatusCode = 401
    
    var surveyItem: SurveyItem {
      SurveyItem(id: id,
                 type: type,
                 attributes: attributes.surveyAttribute)
    }
    
    private enum CodingKeys: String, CodingKey {
      case id, type, attributes
    }
  }
  
  static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [SurveyItem] {
    guard response.statusCode == RemoteSurveyItem.successfulStatusCode else {
      if response.statusCode == RemoteSurveyItem.unauthorizedStatusCode {
        throw RemoteSurveyLoader.Error.unauthorized
      }
      throw RemoteSurveyLoader.Error.invalidData
    }
    
    guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
       throw RemoteSurveyLoader.Error.invalidJSON
    }
    
    return root.surveyItems
  }
}
