//
//  CodableSurveysStore.swift
//  SurveysFeatureTests
//
//  Created by Duy Bui on 9/30/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class CodableSurveysStore {
  func retrieve(completion: @escaping SurveysStore.RetrievalCompletion) {
    completion(.empty)
  }
}

class CodableFeedStoreTests: XCTestCase {

  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = CodableSurveysStore()
    let exp = expectation(description: "Wait for cache retrieval")

    sut.retrieve { result in
      switch result {
      case .empty:
        break

      default:
        XCTFail("Expected empty result, got \(result) instead")
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

}
