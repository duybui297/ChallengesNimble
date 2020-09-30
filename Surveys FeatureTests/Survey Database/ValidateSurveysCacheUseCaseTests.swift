//
//  ValidateSurveysCacheUseCaseTests.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/30/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class ValidateSurveysCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_validateCache_deletesCacheOnRetrievalError() {
    let (sut, store) = makeSUT()
    
    sut.validateCache()
    store.completeRetrieval(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedSurvey])
  }
  
  func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
    let (sut, store) = makeSUT()

    sut.validateCache()
    store.completeRetrievalWithEmptyCache()

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_doesNotDeleteLessThanExpiredDateOldCache() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let lessThanExpiredDateTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    sut.validateCache()
    store.completeRetrieval(with: surveys.local, timestamp: lessThanExpiredDateTimestamp)

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_deletesExpiredDateOldCache() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let sevenDaysOldTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    sut.validateCache()
    store.completeRetrieval(with: surveys.local, timestamp: sevenDaysOldTimestamp)

    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedSurvey])
  }

  func test_validateCache_deletesMoreThanExpiredDateOldCache() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let moreThanExpiredDateTimestamp = fixedCurrentDate.minusSurveysCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    sut.validateCache()
    store.completeRetrieval(with: surveys.local, timestamp: moreThanExpiredDateTimestamp)

    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedSurvey])
  }
  
  func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
    let store = SurveyStoreSpy()
    var sut: LocalSurveysLoader? = LocalSurveysLoader(store: store, currentDate: Date.init)

    sut?.validateCache()

    sut = nil
    store.completeRetrieval(with: anyNSError())

    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
}

// MARK: - Important helper functions
extension ValidateSurveysCacheUseCaseTests {
  private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                       file: StaticString = #file,
                       line: UInt = #line) -> (sut: LocalSurveysLoader, store: SurveyStoreSpy) {
    let store = SurveyStoreSpy()
    let sut = LocalSurveysLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
}

// MARK: - Generating mocking helper functions
extension ValidateSurveysCacheUseCaseTests {
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
}
