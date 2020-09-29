//
//  LoadSurveysFromCacheUseCaseTests.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/29/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class LoadFeedFromCacheUseCaseTests: XCTestCase {
  
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
  
  func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
    let surveys = uniqueSurveyItem()
    let fixedCurrentDate = Date()
    let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    expect(sut, toCompleteWith: .success(surveys.models), when: {
      store.completeRetrieval(with: surveys.local, timestamp: lessThanSevenDaysOldTimestamp)
    })
  }
}

// MARK: - Important helper functions
extension LoadFeedFromCacheUseCaseTests {
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

// MARK: - Generating mocking helper functions
extension LoadFeedFromCacheUseCaseTests {
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func uniqueSurvey() -> Survey {
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
    return Survey(id: UUID().uuidString,
                  type: "any survey",
                  attributes: surveyAttribute)
  }

  private func uniqueSurveyItem() -> (models: [Survey], local: [LocalSurvey]) {
    let models = [uniqueSurvey(), uniqueSurvey()]
    let local = models.map { convertLocalSurvey(from: $0) }
    return (models, local)
  }

  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func convertLocalSurvey(from survey: Survey) -> LocalSurvey {
    let attributes = survey.attributes
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
    return LocalSurvey(id: survey.id,
                       type: survey.type,
                       attributes: localAttributes)
  }
}

private extension Date {
  func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }

  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}
