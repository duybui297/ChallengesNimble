//
//  CodableSurveysStore.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/30/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class CodableSurveysStore {
  private struct Cache: Codable {
    let surveys: [LocalSurvey]
    let timestamp: Date
  }

  private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("surveys.store")
  
  func retrieve(completion: @escaping SurveysStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }

    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(surveys: cache.surveys, timestamp: cache.timestamp))
  }
  
  func insert(_ surveys: [LocalSurvey],
              timestamp: Date,
              completion: @escaping SurveysStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(surveys: surveys, timestamp: timestamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

class CodableSurveysStoreTests: XCTestCase {

  override func setUp() {
    super.setUp()

    let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("surveys.store")
    try? FileManager.default.removeItem(at: storeURL)
  }

  override func tearDown() {
    super.tearDown()

    let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("surveys.store")
    try? FileManager.default.removeItem(at: storeURL)
  }
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = CodableSurveysStore()
    let exp = expectation(description: "Wait for cache retrieval")

    sut.retrieve { result in
      switch result {
      case .empty:
        break

      default:
        XCTFail("Expected empty result, got \(result) instead")
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = CodableSurveysStore()
    let exp = expectation(description: "Wait for cache retrieval")

    sut.retrieve { firstResult in
      sut.retrieve { secondResult in
        switch (firstResult, secondResult) {
        case (.empty, .empty):
          break

        default:
          XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
        }

        exp.fulfill()
      }
    }

    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    let sut = CodableSurveysStore()
    let surveys = uniqueSurveyItem().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache retrieval")

    sut.insert(surveys, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected surveys to be inserted successfully")

      sut.retrieve { retrieveResult in
        switch retrieveResult {
        case let .found(retrievedSurveys, retrievedTimestamp):
          XCTAssertEqual(retrievedSurveys, surveys)
          XCTAssertEqual(retrievedTimestamp, timestamp)

        default:
          XCTFail("Expected found result with surveys \(surveys) and timestamp \(timestamp), got \(retrieveResult) instead")
        }

        exp.fulfill()
      }
    }

    wait(for: [exp], timeout: 1.0)
  }

}
