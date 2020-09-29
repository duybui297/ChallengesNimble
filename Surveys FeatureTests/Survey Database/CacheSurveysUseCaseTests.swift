//
//  CacheSurveysUseCaseTests.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class LocalSurveysLoader {
  private let store: SurveyStore
  
  init(store: SurveyStore) {
    self.store = store
  }
  
  func saveWith(_ items: [SurveyItem]) {
    store.deleteCachedSurveys()
  }
}

class SurveyStore {
  var deleteCachedSurveysCallCount = 0
  var insertCallCount = 0
  
  func deleteCachedSurveys() {
    deleteCachedSurveysCallCount += 1
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {

  }
}

class CacheSurveysUseCaseTests: XCTestCase {

  func test_init_doesNotDeleteCacheUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.deleteCachedSurveysCallCount, 0)
  }

  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]

    sut.saveWith(items)

    XCTAssertEqual(store.deleteCachedSurveysCallCount, 1)
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()

    sut.saveWith(items)
    store.completeDeletion(with: deletionError)

    XCTAssertEqual(store.insertCallCount, 0)
  }
}

// MARK: - Important helper functions
extension CacheSurveysUseCaseTests {
  private func makeSUT(file: StaticString = #file,
                       line: UInt = #line) -> (sut: LocalSurveysLoader, store: SurveyStore) {
    let store = SurveyStore()
    let sut = LocalSurveysLoader(store: store)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
}

// MARK: - Generating mocking helper functions
extension CacheSurveysUseCaseTests {
  private func uniqueItem() -> SurveyItem {
    let surveyAttribute = SurveyAttribute(title: "any title",
                                          description: "any description",
                                          thankEmailAboveThreshold: "any thank email above",
                                          thankEmailBelowThreshold: "any thank email below",
                                          isActive: true,
                                          coverImageURL: anyURL(),
                                          createdAt: "any creation date",
                                          activeAt: "any activation date",
                                          inactiveAt: nil,
                                          surveyType: "any survey type")
    return SurveyItem(id: UUID().uuidString,
                      type: "any survey",
                      attributes: surveyAttribute)
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
}
