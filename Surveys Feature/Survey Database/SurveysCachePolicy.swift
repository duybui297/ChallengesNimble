//
//  SurveysCachePolicy.swift
//  SurveysFeature
//
//  Created by Duy Bui on 9/30/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

final class SurveysCachePolicy {
  private init() {}
  
  private static let calendar = Calendar(identifier: .gregorian)
  private static var maxCacheAgeInDays: Int {
    return 7
  }
  
  static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
      return false
    }
    return date < maxCacheAge
  }
}
