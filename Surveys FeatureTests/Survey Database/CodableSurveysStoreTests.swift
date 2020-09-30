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
    
    do {
      let decoder = JSONDecoder()
      let cache = try decoder.decode(Cache.self, from: data)
      completion(.found(surveys: cache.localSurveys, timestamp: cache.timestamp))
    } catch {
      completion(.failure(error))
    }
  }
  
  func insert(_ surveys: [LocalSurvey],
              timestamp: Date,
              completion: @escaping SurveysStore.InsertionCompletion) {
    do {
      let encoder = JSONEncoder()
      let cache = Cache(surveys: surveys.map(CodableSurveys.init), timestamp: timestamp)
      let encoded = try encoder.encode(cache)
      try encoded.write(to: storeURL)
      completion(nil)
    } catch {
      completion(error)
    }
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
    expect(sut, toRetrieveTwice: .empty)
  }
  
  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    let surveys = uniqueSurveyItem().local
    let timestamp = Date()
    
    insert((surveys, timestamp), to: sut)
    expect(sut, toRetrieve: .found(surveys: surveys, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let surveys = uniqueSurveyItem().local
    let timestamp = Date()
    
    insert((surveys, timestamp), to: sut)
    expect(sut, toRetrieveTwice: .found(surveys: surveys, timestamp: timestamp))
  }
  
  func test_retrieve_deliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    
    expect(sut, toRetrieve: .failure(anyNSError()))
  }
  
  func test_retrieve_hasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)

    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

    expect(sut, toRetrieveTwice: .failure(anyNSError()))
  }
  
  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()

    let firstInsertionError = insert((uniqueSurveyItem().local, Date()), to: sut)
    XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")

    let latestSurveys = uniqueSurveyItem().local
    let latestTimestamp = Date()
    let latestInsertionError = insert((latestSurveys, latestTimestamp), to: sut)

    XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
    expect(sut, toRetrieve: .found(surveys: latestSurveys, timestamp: latestTimestamp))
  }
  
  func test_insert_deliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)
    let surveys = uniqueSurveyItem().local
    let timestamp = Date()

    let insertionError = insert((surveys, timestamp), to: sut)

    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    expect(sut, toRetrieve: .empty)
  }
}

// MARK: - Important helper functions
extension CodableSurveysStoreTests {
  private func makeSUT(storeURL: URL? = nil,
                       file: StaticString = #file,
                       line: UInt = #line) -> CodableSurveysStore {
    let sut = CodableSurveysStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  @discardableResult
  private func insert(_ cache: (surveys: [LocalSurvey], timestamp: Date), to sut: CodableSurveysStore) -> Error? {
    let exp = expectation(description: "Wait for cache insertion")
    var insertionError: Error?
    sut.insert(cache.surveys, timestamp: cache.timestamp) { receivedInsertionError in
      insertionError = receivedInsertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }
  
  private func expect(_ sut: CodableSurveysStore,
                      toRetrieveTwice expectedResult: RetrieveCachedSurveysResult,
                      file: StaticString = #file,
                      line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  private func expect(_ sut: CodableSurveysStore,
                      toRetrieve expectedResult: RetrieveCachedSurveysResult,
                      file: StaticString = #file,
                      line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { retrievedResult in
      switch (expectedResult, retrievedResult) {
      case (.empty, .empty), (.failure, .failure):
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
