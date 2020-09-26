//
//  RemoteSurveyLoaderTests.swift
//  Surveys FeatureTests
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest

class RemoteSurveyLoader {
  func load() {}
}

class RemoteSurveyLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let sut = RemoteSurveyLoader()
    let client = HTTPClientSpy()
    sut.load()
    XCTAssertNil(client.requestedURL)
  }
  
  private class HTTPClientSpy {
    var requestedURL: URL?
  }
}
