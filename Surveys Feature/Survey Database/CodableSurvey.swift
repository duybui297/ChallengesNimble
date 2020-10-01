//
//  CodableSurvey.swift
//  SurveysFeature
//
//  Created by Duy Bui on 10/1/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public struct CodableSurveysAttribute: Codable {
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
  
  public init(_ localSurverAttribute: LocalSurveyAttribute) {
    self.title = localSurverAttribute.title
    self.description = localSurverAttribute.description
    self.thankEmailAboveThreshold = localSurverAttribute.thankEmailAboveThreshold
    self.thankEmailBelowThreshold = localSurverAttribute.thankEmailBelowThreshold
    self.isActive = localSurverAttribute.isActive
    self.coverImageURL = localSurverAttribute.coverImageURL
    self.createdAt = localSurverAttribute.createdAt
    self.activeAt = localSurverAttribute.activeAt
    self.inactiveAt = localSurverAttribute.inactiveAt
    self.surveyType = localSurverAttribute.surveyType
  }
  
  public var local: LocalSurveyAttribute {
    return LocalSurveyAttribute(title: title,
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
}

public struct CodableSurveys: Codable {
  let id: String
  let type: String
  let attributes: CodableSurveysAttribute
  
  public init(_ localSurvey: LocalSurvey) {
    self.id = localSurvey.id
    self.type = localSurvey.type
    self.attributes = CodableSurveysAttribute(localSurvey.attributes)
  }
  
  public var local: LocalSurvey {
    return LocalSurvey(id: id,
                       type: type,
                       attributes: attributes.local)
  }
}
