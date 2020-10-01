//
//  SurveysStoreSpy.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation
import SurveysFeature

class SurveyStoreSpy: SurveysStore {
  enum ReceivedMessage: Equatable {
    case deleteCachedSurvey
    case insert([LocalSurvey], Date)
    case retrieve
  }
  
  private(set) var receivedMessages = [ReceivedMessage]()
  private var deletionCompletions = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()
  private var retrievalCompletions = [RetrievalCompletion]()
  
  func deleteCachedSurveys(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedSurvey)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }
  
  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }
  
  func insert(_ surveys: [LocalSurvey], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(surveys, timestamp))
  }
  
  func retrieve(completion: @escaping RetrievalCompletion) {
    retrievalCompletions.append(completion)
    receivedMessages.append(.retrieve)
  }
  
  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }
  
  func completeRetrievalWithEmptyCache(at index: Int = 0) {
    retrievalCompletions[index](.success(.empty))
  }
  
  func completeRetrieval(with surveys: [LocalSurvey], timestamp: Date, at index: Int = 0) {
    retrievalCompletions[index](.success(.found(surveys: surveys, timestamp: timestamp)))
  }
}
