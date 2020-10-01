//
//  CodableSurveysStore.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/30/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

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
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    let deletionError = deleteCache(from: sut)
    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()
    insert((uniqueSurveyItem().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_deliversErrorOnDeletionError() {
    let noDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePermissionURL)

    let deletionError = deleteCache(from: sut)

    XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    expect(sut, toRetrieve: .empty)
  }
}

// MARK: - Important helper functions
extension CodableSurveysStoreTests {
  private func makeSUT(storeURL: URL? = nil,
                       file: StaticString = #file,
                       line: UInt = #line) -> SurveysStore {
    let sut = CodableSurveysStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  @discardableResult
  private func insert(_ cache: (surveys: [LocalSurvey], timestamp: Date),
                      to sut: SurveysStore) -> Error? {
    let exp = expectation(description: "Wait for cache insertion")
    var insertionError: Error?
    sut.insert(cache.surveys, timestamp: cache.timestamp) { receivedInsertionError in
      insertionError = receivedInsertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }
  
  private func deleteCache(from sut: SurveysStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion")
    var deletionError: Error?
    sut.deleteCachedSurveys { receivedDeletionError in
      deletionError = receivedDeletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }
  
  private func expect(_ sut: SurveysStore,
                      toRetrieveTwice expectedResult: RetrieveCachedSurveysResult,
                      file: StaticString = #file,
                      line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  private func expect(_ sut: SurveysStore,
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
    return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }
  
  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
