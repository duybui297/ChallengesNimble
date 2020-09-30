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

  public init(store: SurveysStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
}

extension LocalSurveysLoader {
  public typealias SaveResult = Error?
  
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
}

extension LocalSurveysLoader: SurveyLoader {
  public typealias LoadResult = SurveyLoaderResult
  
  public func load(completion: @escaping (LoadResult) -> Void) {
    store.retrieve { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .failure(error):
        completion(.failure(error))
      case let .found(surveys, timestamp) where SurveysCachePolicy.validate(timestamp, against: self.currentDate()):
        completion(.success(surveys.toModels()))
      case .found, .empty:
        completion(.success([]))
      }
    }
  }
}

extension LocalSurveysLoader {
  public func validateCache() {
    store.retrieve { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure:
        self.store.deleteCachedSurveys { _ in }
        
      case let .found(_, timestamp) where !SurveysCachePolicy.validate(timestamp, against: self.currentDate()):
        self.store.deleteCachedSurveys { _ in }
        
      case .empty, .found: break
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

private extension Array where Element == LocalSurvey {
  func toModels() -> [Survey] {
    return map { localSurvey in
      let localSurveyAttributes = localSurvey.attributes
      let attributes = SurveyAttribute(title: localSurveyAttributes.title,
                                       description: localSurveyAttributes.description,
                                       thankEmailAboveThreshold: localSurveyAttributes.thankEmailAboveThreshold,
                                       thankEmailBelowThreshold: localSurveyAttributes.thankEmailBelowThreshold,
                                       isActive: localSurveyAttributes.isActive,
                                       coverImageURL: localSurveyAttributes.coverImageURL,
                                       createdAt: localSurveyAttributes.createdAt,
                                       activeAt: localSurveyAttributes.activeAt,
                                       inactiveAt: localSurveyAttributes.inactiveAt,
                                       surveyType: localSurveyAttributes.surveyType)
      return Survey(id: localSurvey.id,
                    type: localSurvey.type,
                    attributes: attributes)
    }
  }
}
