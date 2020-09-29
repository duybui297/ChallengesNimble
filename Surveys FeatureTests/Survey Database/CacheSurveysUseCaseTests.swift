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
  private let currentDate: () -> Date
  
  init(store: SurveyStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  func saveWith(_ items: [SurveyItem]) {
    store.deleteCachedSurveys { [unowned self] error in
      if error == nil {
        self.store.insert(items, timestamp: self.currentDate())
      }
    }
  }
}

class SurveyStore {
  typealias DeletionCompletion = (Error?) -> Void
  
  enum ReceivedMessage: Equatable {
    case deleteCachedFeed
    case insert([SurveyItem], Date)
  }

  private(set) var receivedMessages = [ReceivedMessage]()
  private var deletionCompletions = [DeletionCompletion]()
  
  func deleteCachedSurveys(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {

  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }

  func insert(_ items: [SurveyItem], timestamp: Date) {
    receivedMessages.append(.insert(items, timestamp))
  }
}

class CacheSurveysUseCaseTests: XCTestCase {

  func test_init_doesNotPerformAnythingWithStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]

    sut.saveWith(items)

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()

    sut.saveWith(items)
    store.completeDeletion(with: deletionError)

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT(currentDate: { timestamp })

    sut.saveWith(items)
    store.completeDeletionSuccessfully()

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
  }
}

// MARK: - Important helper functions
extension CacheSurveysUseCaseTests {
  private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                       file: StaticString = #file,
                       line: UInt = #line) -> (sut: LocalSurveysLoader, store: SurveyStore) {
    let store = SurveyStore()
    let sut = LocalSurveysLoader(store: store, currentDate: currentDate)
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
