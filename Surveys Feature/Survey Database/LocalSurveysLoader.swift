//
//  LocalSurveysLoader.swift
//  SurveysFeature
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public final class LocalSurveysLoader {
  private let store: SurveyStore
  private let currentDate: () -> Date
  
  public init(store: SurveyStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func save(_ items: [SurveyItem], completion: @escaping (Error?) -> Void) {
    store.deleteCachedSurveys { [weak self] error in
      guard let self = self else { return }
      if error == nil {
        self.cache(items, with: completion)
      } else {
        completion(error)
      }
    }
  }
  
  private func cache(_ items: [SurveyItem], with completion: @escaping (Error?) -> Void) {
    store.insert(items, timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}

public protocol SurveyStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void

  func deleteCachedSurveys(completion: @escaping DeletionCompletion)
  func insert(_ items: [SurveyItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
