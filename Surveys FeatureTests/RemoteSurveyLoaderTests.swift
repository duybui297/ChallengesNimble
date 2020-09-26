//
//  RemoteSurveyLoaderTests.swift
//  Surveys FeatureTests
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest

protocol HTTPClient {
  func get(from url: URL)
}

class RemoteSurveyLoader {
  private let httpClient: HTTPClient
  private let url: URL
  
  init(httpClient: HTTPClient, url: URL) {
    self.httpClient = httpClient
    self.url = url
  }
  
  func load() {
    httpClient.get(from: url)
  }
}

class RemoteSurveyLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let url = URL(string: "https://any-url.com")
    let client = HTTPClientSpy()
    let sut = RemoteSurveyLoader(httpClient: client, url: url!)
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let url = URL(string: "https://a-specific-url.com")
    let client = HTTPClientSpy()
    let sut = RemoteSurveyLoader(httpClient: client, url: url!)
    sut.load()
    XCTAssertEqual(client.requestedURL, url)
  }
  
  private class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
      requestedURL = url
    }
  }
}
