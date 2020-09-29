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
  
  func deleteCachedSurveys() {
    deleteCachedSurveysCallCount += 1
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
}

// MARK: - Important helper functions
extension CacheSurveysUseCaseTests {
  private func makeSUT() -> (sut: LocalSurveysLoader, store: SurveyStore) {
    let store = SurveyStore()
    let sut = LocalSurveysLoader(store: store)
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
}
