//
//  SurveyItem.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public struct SurveyAttribute: Equatable, Decodable {
  public let title: String
  public let description: String
  public let thankEmailAboveThreshold: String?
  public let thankEmailBelowThreshold: String?
  public let isActive: Bool
  public let coverImageURL: URL
  public let createdAt: String
  public let activeAt: String
  public let inactiveAt: String?
  public let surveyType: String
  
  public init(title: String,
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

public struct SurveyItem: Equatable, Decodable {
  public let id: String
  public let type: String
  public let attributes: SurveyAttribute
  
  public init(id: String, type: String, attributes: SurveyAttribute) {
    self.id = id
    self.type = type
    self.attributes = attributes
  }
  
  private enum CodingKeys: String, CodingKey {
    case id, type, attributes
  }
}
