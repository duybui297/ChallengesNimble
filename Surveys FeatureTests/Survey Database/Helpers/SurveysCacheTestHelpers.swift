//
//  SurveysCacheTestHelpers.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/30/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation
import SurveysFeature

func uniqueSurvey() -> Survey {
  let surveyAttribute = SurveyAttribute(title: "any title",
                                        description: "any description",
                                        thankEmailAboveThreshold: "any thank email above",
                                        thankEmailBelowThreshold: "any thank email below",
                                        isActive: true,
                                        coverImageURL: anyURL(),
                                        createdAt: "any creation date",
                                        activeAt: "any activation date",
                                        inactiveAt: nil,
                                        surveyType: "any survey type")
  return Survey(id: UUID().uuidString,
                type: "any survey",
                attributes: surveyAttribute)
}

func uniqueSurveyItem() -> (models: [Survey], local: [LocalSurvey]) {
  let models = [uniqueSurvey(), uniqueSurvey()]
  let local = models.map { convertLocalSurvey(from: $0) }
  return (models, local)
}

func convertLocalSurvey(from survey: Survey) -> LocalSurvey {
  let attributes = survey.attributes
  let localAttributes = LocalSurveyAttribute(title: attributes.title,
                                             description: attributes.description,
                                             thankEmailAboveThreshold: attributes.thankEmailAboveThreshold,
                                             thankEmailBelowThreshold: attributes.thankEmailBelowThreshold,
                                             isActive: attributes.isActive,
                                             coverImageURL: attributes.coverImageURL,
                                             createdAt: attributes.createdAt,
                                             activeAt: attributes.activeAt,
                                             inactiveAt: attributes.inactiveAt,
                                             surveyType: attributes.surveyType)
  return LocalSurvey(id: survey.id,
                     type: survey.type,
                     attributes: localAttributes)
}

extension Date {
  func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}
