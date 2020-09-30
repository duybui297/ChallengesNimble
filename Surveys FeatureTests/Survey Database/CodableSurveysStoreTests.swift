//
//  CodableSurveysStore.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/30/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

struct CodableSurveysAttribute: Codable {
  let title: String
  let description: String
  let thankEmailAboveThreshold: String?
  let thankEmailBelowThreshold: String?
  let isActive: Bool
  let coverImageURL: URL
  let createdAt: String
  let activeAt: String
  let inactiveAt: String?
  let surveyType: String
  
  init(_ localSurverAttribute: LocalSurveyAttribute) {
    self.title = localSurverAttribute.title
    self.description = localSurverAttribute.description
    self.thankEmailAboveThreshold = localSurverAttribute.thankEmailAboveThreshold
    self.thankEmailBelowThreshold = localSurverAttribute.thankEmailBelowThreshold
    self.isActive = localSurverAttribute.isActive
    self.coverImageURL = localSurverAttribute.coverImageURL
    self.createdAt = localSurverAttribute.createdAt
    self.activeAt = localSurverAttribute.activeAt
    self.inactiveAt = localSurverAttribute.inactiveAt
    self.surveyType = localSurverAttribute.surveyType
  }
  
  var local: LocalSurveyAttribute {
    return LocalSurveyAttribute(title: title,
                                description: description,
                                thankEmailAboveThreshold: thankEmailAboveThreshold,
                                thankEmailBelowThreshold: thankEmailBelowThreshold,
                                isActive: isActive,
                                coverImageURL: coverImageURL,
                                createdAt: createdAt,
                                activeAt: activeAt,
                                inactiveAt: inactiveAt,
                                surveyType: surveyType)
  }
}

struct CodableSurveys: Codable {
  let id: String
  let type: String
  let attributes: CodableSurveysAttribute
  
  init(_ localSurvey: LocalSurvey) {
    self.id = localSurvey.id
    self.type = localSurvey.type
    self.attributes = CodableSurveysAttribute(localSurvey.attributes)
  }
  
  var local: LocalSurvey {
    return LocalSurvey(id: id,
                       type: type,
                       attributes: attributes.local)
  }
}

class CodableSurveysStore {
  private struct Cache: Codable {
    let surveys: [CodableSurveys]
    let timestamp: Date
    
    var localSurveys: [LocalSurvey] {
      return surveys.map { $0.local }
    }
  }

  private let storeURL: URL

  init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  func retrieve(completion: @escaping SurveysStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }

    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(surveys: cache.localSurveys, timestamp: cache.timestamp))
  }
  
  func insert(_ surveys: [LocalSurvey],
              timestamp: Date,
              completion: @escaping SurveysStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(surveys: surveys.map(CodableSurveys.init), timestamp: timestamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

class CodableSurveysStoreTests: XCTestCase {

  override func setUp() {
    super.setUp()

    setupEmptyStoreState()
  }

  override func tearDown() {
    super.tearDown()

    undoStoreSideEffects()
  }
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    expect(sut, toRetrieve: .empty)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
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
    let sut = makeSUT()
    let surveys = uniqueSurveyItem().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.insert(surveys, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected surveys to be inserted successfully")
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
    expect(sut, toRetrieve: .found(surveys: surveys, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let surveys = uniqueSurveyItem().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache retrieval")

    sut.insert(surveys, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected surveys to be inserted successfully")

      sut.retrieve { firstResult in
        sut.retrieve { secondResult in
          switch (firstResult, secondResult) {
          case let (.found(firstFound), .found(secondFound)):
            XCTAssertEqual(firstFound.surveys, surveys)
            XCTAssertEqual(firstFound.timestamp, timestamp)

            XCTAssertEqual(secondFound.surveys, surveys)
            XCTAssertEqual(secondFound.timestamp, timestamp)

          default:
            XCTFail("Expected retrieving twice from non empty cache to deliver same found result with surveys \(surveys) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead")
          }

          exp.fulfill()
        }
      }
    }

    wait(for: [exp], timeout: 1.0)
  }
}

// MARK: - Important helper functions
extension CodableSurveysStoreTests {
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableSurveysStore {
    let sut = CodableSurveysStore(storeURL: testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func expect(_ sut: CodableSurveysStore,
                      toRetrieve expectedResult: RetrieveCachedSurveysResult,
                      file: StaticString = #file,
                      line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { retrievedResult in
      switch (expectedResult, retrievedResult) {
      case (.empty, .empty):
        break
        
      case let (.found(expected), .found(retrieved)):
        XCTAssertEqual(retrieved.surveys, expected.surveys, file: file, line: line)
        XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
        
      default:
        XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  private func testSpecificStoreURL() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
  }
}

// MARK: - Self-documentation for functions in setup and teardown
extension CodableSurveysStoreTests {
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }

  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }

  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
}
