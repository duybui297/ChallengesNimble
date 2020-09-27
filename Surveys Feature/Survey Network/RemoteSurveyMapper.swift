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
    
    init(title: String,
         description: String,
         thankEmailAboveThreshold: String?,
         thankEmailBelowThreshold: String?,
         isActive: Bool,
         coverImageURL: URL,
         createdAt: String,
         activeAt: String,
         inactiveAt: String?,
         surveyType: String) {
      self.title = title
      self.description = description
      self.thankEmailAboveThreshold = thankEmailAboveThreshold
      self.thankEmailBelowThreshold = thankEmailBelowThreshold
      self.isActive = isActive
      self.coverImageURL = coverImageURL
      self.createdAt = createdAt
      self.activeAt = activeAt
      self.inactiveAt = inactiveAt
      self.surveyType = surveyType
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
    var surveyItem: SurveyItem {
      SurveyItem(id: id,
                 type: type,
                 attributes: attributes.surveyAttribute)
    }
    
    init(id: String, type: String, attributes: RemoteSurveyAttribute) {
      self.id = id
      self.type = type
      self.attributes = attributes
    }
    
    private enum CodingKeys: String, CodingKey {
      case id, type, attributes
    }
  }
  
  static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [SurveyItem] {
    guard response.statusCode == RemoteSurveyItem.successfulStatusCode else {
      throw RemoteSurveyLoader.Error.invalidData
    }
    
    guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
       throw RemoteSurveyLoader.Error.invalidJSON
    }
    
    return root.surveyItems
  }
}
