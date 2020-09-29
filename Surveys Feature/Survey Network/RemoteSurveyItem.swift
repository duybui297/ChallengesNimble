//
//  RemoteSurvey.swift
//  SurveysFeature
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

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

struct RemoteSurvey: Equatable, Decodable {
  let id: String
  let type: String
  let attributes: RemoteSurveyAttribute
  
  static let successfulStatusCode = 200
  static let unauthorizedStatusCode = 401
  
  var surveyItem: Survey {
    Survey(id: id,
               type: type,
               attributes: attributes.surveyAttribute)
  }
  
  private enum CodingKeys: String, CodingKey {
    case id, type, attributes
  }
}
