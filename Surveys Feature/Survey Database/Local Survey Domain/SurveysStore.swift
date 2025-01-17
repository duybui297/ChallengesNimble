//
//  SurveysStore.swift
//  SurveysFeature
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public typealias CachedSurveys = (surveys: [LocalSurvey], timestamp: Date)

public protocol SurveysStore {
  typealias DeletionResult = Error?
  typealias DeletionCompletion = (DeletionResult) -> Void

  typealias InsertionResult = Error?
  typealias InsertionCompletion = (InsertionResult) -> Void
  
  typealias RetrievalResult = Result<CachedSurveys?, Error>
  typealias RetrievalCompletion = (RetrievalResult) -> Void
  
  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func deleteCachedSurveys(completion: @escaping DeletionCompletion)
  
  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func insert(_ surveys: [LocalSurvey], timestamp: Date, completion: @escaping InsertionCompletion)
  
  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func retrieve(completion: @escaping RetrievalCompletion)
}
