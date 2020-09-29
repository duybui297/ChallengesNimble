//
//  CacheSurveysUseCaseTests.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class CacheSurveysUseCaseTests: XCTestCase {

  func test_init_doesNotPerformAnythingWithStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]

    sut.save(items) { _ in }

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()

    sut.save(items) { _ in }
    store.completeDeletion(with: deletionError)

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let localItems = items.map { convertLocalItems(from: $0) }
    sut.save(items) { _ in }
    store.completeDeletionSuccessfully()

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(localItems, timestamp)])
  }
  
  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    expect(sut, toCompleteWithError: deletionError, when: {
      store.completeDeletion(with: deletionError)
    })
  }
  
  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()
    expect(sut, toCompleteWithError: insertionError, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertion(with: insertionError)
    })
  }
  
  func test_save_succeedsOnSuccessfulCacheInsertion() {
    let (sut, store) = makeSUT()
    expect(sut, toCompleteWithError: nil, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertionSuccessfully()
    })
  }
  
  func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = SurveyStoreSpy()
    var sut: LocalSurveysLoader? = LocalSurveysLoader(store: store, currentDate: Date.init)

    var receivedResults = [LocalSurveysLoader.SaveResult]()
    sut?.save([uniqueItem()]) { receivedResults.append($0) }

    sut = nil
    store.completeDeletion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = SurveyStoreSpy()
    var sut: LocalSurveysLoader? = LocalSurveysLoader(store: store, currentDate: Date.init)

    var receivedResults = [LocalSurveysLoader.SaveResult]()
    sut?.save([uniqueItem()]) { receivedResults.append($0) }

    store.completeDeletionSuccessfully()
    sut = nil
    store.completeInsertion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }
}

// MARK: - Important helper functions
extension CacheSurveysUseCaseTests {
  private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                       file: StaticString = #file,
                       line: UInt = #line) -> (sut: LocalSurveysLoader, store: SurveyStoreSpy) {
    let store = SurveyStoreSpy()
    let sut = LocalSurveysLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
  
  private func expect(_ sut: LocalSurveysLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for save completion")

    var receivedError: Error?
    sut.save([uniqueItem()]) { error in
      receivedError = error
      exp.fulfill()
    }

    action()
    wait(for: [exp], timeout: 1.0)

    XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
  }
}

// MARK: - Spy - Stub classes
extension CacheSurveysUseCaseTests {
  private class SurveyStoreSpy: SurveysStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    enum ReceivedMessage: Equatable {
      case deleteCachedFeed
      case insert([LocalSurveyItem], Date)
    }

    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    func deleteCachedSurveys(completion: @escaping DeletionCompletion) {
      deletionCompletions.append(completion)
      receivedMessages.append(.deleteCachedFeed)
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

    func insert(_ items: [LocalSurveyItem], timestamp: Date, completion: @escaping InsertionCompletion) {
      insertionCompletions.append(completion)
      receivedMessages.append(.insert(items, timestamp))
    }
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
  
  private func convertLocalItems(from surveyItem: SurveyItem) -> LocalSurveyItem {
    let attributes = surveyItem.attributes
    let localAttributes = LocalSurveyAttribute(title: attributes.title,
                                               description: attributes.description,
                                               thankEmailAboveThreshold: attributes.thankEmailAboveThreshold,
                                               thankEmailBelowThreshold: attributes.thankEmailBelowThreshold,
                                               isActive: attributes.isActive,
                                               coverImageURL: attributes.coverImageURL,
                                               createdAt: attributes.createdAt,
                                               activeAt: attributes.activeAt,
                                               inactiveAt: attributes.inactiveAt,
                                               surveyType: attributes.surveyType)
    return LocalSurveyItem(id: surveyItem.id,
                               type: surveyItem.type,
                               attributes: localAttributes)
  }
}
