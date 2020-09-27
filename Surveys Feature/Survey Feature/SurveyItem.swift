//
//  SurveyItem.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public struct SurveyAttribute: Equatable {
  let title: String
  let description: String
  let thankEmailAboveThreshold: String?
  let thankEmailBelowThreshold: String?
  let isActive: Bool
  let coverImageURL: String
  let createdAt: String
  let activeAt: String
  let inactiveAt: String?
  let surveyType: String
}

public struct SurveyItem: Equatable {
  let id: String
  let attributes: SurveyAttribute
}
