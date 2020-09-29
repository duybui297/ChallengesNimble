//
//  LocalSurveysLoader.swift
//  SurveysFeature
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public final class LocalSurveysLoader {
  private let store: SurveysStore
  private let currentDate: () -> Date
  
  public typealias SaveResult = Error?
  
  public init(store: SurveysStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func save(_ items: [SurveyItem], completion: @escaping (SaveResult) -> Void) {
    store.deleteCachedSurveys { [weak self] error in
      guard let self = self else { return }
      if error == nil {
        self.cache(items, with: completion)
      } else {
        completion(error)
      }
    }
  }
  
  private func cache(_ items: [SurveyItem], with completion: @escaping (SaveResult) -> Void) {
    store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}

private extension Array where Element == SurveyItem {
  func toLocal() -> [LocalSurveyItem] {
    return map { surveyItem in
      let attributes = surveyItem.attributes
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
      return LocalSurveyItem(id: surveyItem.id,
                                 type: surveyItem.type,
                                 attributes: localAttributes)
    }
  }
}
