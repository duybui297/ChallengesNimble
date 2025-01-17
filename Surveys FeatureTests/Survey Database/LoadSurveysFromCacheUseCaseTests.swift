//
//  LoadSurveysFromCacheUseCaseTests.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class LoadSurveysFromCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_load_requestsCacheRetrieval() {
    let (sut, store) = makeSUT()
    
    sut.load { _ in }
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_failsOnRetrievalError() {
    let (sut, store) = makeSUT()
    let retrievalError = anyNSError()
    
    expect(sut, toCompleteWith: .failure(retrievalError), when: {
      store.completeRetrieval(with: retrievalError)
    })
  }
  
  func test_load_deliversNoSurveysOnEmptyCache() {
    let (sut, store) = makeSUT()
    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrievalWithEmptyCache()
    })
  }
  
  func test_load_deliversCachedSurveysOnNonExpiredCache() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let nonExpiredTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    expect(sut, toCompleteWith: .success(surveys.models), when: {
      store.completeRetrieval(with: surveys.local, timestamp: nonExpiredTimestamp)
    })
  }
  
  func test_load_deliversNoSurveysOnCacheExpiration() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let expirationTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrieval(with: surveys.local, timestamp: expirationTimestamp)
    })
  }
  
  func test_load_deliversNoImagesOnExpiredCache() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let expiredTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrieval(with: surveys.local, timestamp: expiredTimestamp)
    })
  }
  
  func test_load_hasNoSideEffectsOnRetrievalError() {
    let (sut, store) = makeSUT()

    sut.load { _ in }
    store.completeRetrieval(with: anyNSError())

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_hasNoSideEffectsOnEmptyCache() {
    let (sut, store) = makeSUT()

    sut.load { _ in }
    store.completeRetrievalWithEmptyCache()

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_hasNoSideEffectsOnExpiredCache() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let expiredTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    sut.load { _ in }
    store.completeRetrieval(with: surveys.local, timestamp: expiredTimestamp)

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_hasNoSideEffectsOnNonExpiredCache() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let nonExpiredTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    sut.load { _ in }
    store.completeRetrieval(with: surveys.local, timestamp: nonExpiredTimestamp)

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_hasNoSideEffectsOnCacheExpiration() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let expirationTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    sut.load { _ in }
    store.completeRetrieval(with: surveys.local, timestamp: expirationTimestamp)

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let store = SurveyStoreSpy()
    var sut: LocalSurveysLoader? = LocalSurveysLoader(store: store, currentDate: Date.init)

    var receivedResults = [LocalSurveysLoader.LoadResult]()
    sut?.load { receivedResults.append($0) }

    sut = nil
    store.completeRetrievalWithEmptyCache()

    XCTAssertTrue(receivedResults.isEmpty)
  }

}

// MARK: - Important helper functions
extension LoadSurveysFromCacheUseCaseTests {
  private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                       file: StaticString = #file,
                       line: UInt = #line) -> (sut: LocalSurveysLoader, store: SurveyStoreSpy) {
    let store = SurveyStoreSpy()
    let sut = LocalSurveysLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
  
  private func expect(_ sut: LocalSurveysLoader,
                      toCompleteWith expectedResult: LocalSurveysLoader.LoadResult,
                      when action: () -> Void,
                      file: StaticString = #file,
                      line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")

    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedSurveys), .success(expectedSurveys)):
        XCTAssertEqual(receivedSurveys, expectedSurveys, file: file, line: line)

      case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)

      default:
        XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    action()
    wait(for: [exp], timeout: 1.0)
  }
}
