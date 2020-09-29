//
//  SurveysStore.swift
//  SurveysFeature
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public protocol SurveysStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  typealias RetrievalCompletion = (Error?) -> Void
  
  func deleteCachedSurveys(completion: @escaping DeletionCompletion)
  func insert(_ surveys: [LocalSurvey], timestamp: Date, completion: @escaping InsertionCompletion)
  func retrieve(completion: @escaping RetrievalCompletion)
}
