//
//  SurveyItem.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

struct SurveyAttribute {
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

struct SurveyItem {
  let id: String
  let attributes: SurveyAttribute
}
