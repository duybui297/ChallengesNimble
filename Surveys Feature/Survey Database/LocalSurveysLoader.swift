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
  public typealias LoadResult = SurveyLoaderResult
  
  public init(store: SurveysStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func save(_ surveys: [Survey], completion: @escaping (SaveResult) -> Void) {
    store.deleteCachedSurveys { [weak self] error in
      guard let self = self else { return }
      if error == nil {
        self.cache(surveys, with: completion)
      } else {
        completion(error)
      }
    }
  }
  
  private func cache(_ surveys: [Survey], with completion: @escaping (SaveResult) -> Void) {
    store.insert(surveys.toLocal(), timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
  
  public func load(completion: @escaping (LoadResult) -> Void) {
    store.retrieve { error in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success([]))
      }
    }
  }
}

private extension Array where Element == Survey {
  func toLocal() -> [LocalSurvey] {
    return map { survey in
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
  }
}
