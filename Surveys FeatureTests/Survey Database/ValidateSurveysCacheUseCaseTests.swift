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
