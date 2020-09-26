//
//  RemoteSurveyLoaderTests.swift
//  Surveys FeatureTests
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest

protocol HTTPClient {
  func get(from url: URL, userTokenType: String, userAccessToken: String)
}

class RemoteSurveyLoader {
  private let httpClient: HTTPClient
  private let url: URL
  private let userTokenType: String
  private let userAccessToken: String
  
  init(httpClient: HTTPClient,
       url: URL,
       userTokenType: String,
       userAccessToken: String) {
    self.httpClient = httpClient
    self.url = url
    self.userTokenType = userTokenType
    self.userAccessToken = userAccessToken
  }
  
  func load() {
    httpClient.get(from: url,
                   userTokenType: userTokenType,
                   userAccessToken: userAccessToken)
  }
}

class RemoteSurveyLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURLAndParameters() {
    let url = URL(string: "https://any-url.com")
    let userTokenType = "Any User Token Type"
    let userAccessToken = "Any User Access Token"
    let client = HTTPClientSpy()
    let _ = RemoteSurveyLoader(httpClient: client,
                               url: url!,
                               userTokenType: userTokenType,
                               userAccessToken: userAccessToken)
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURLAndParameters() {
    let url = URL(string: "https://a-specific-url.com")
    let userTokenType = "A Specific User Token Type"
    let userAccessToken = "A Specific User Access Token"
    let client = HTTPClientSpy()
    let sut = RemoteSurveyLoader(httpClient: client,
                                 url: url!,
                                 userTokenType: userTokenType,
                                 userAccessToken: userAccessToken)
    sut.load()
    XCTAssertEqual(client.requestedURL, url)
  }
  
  private class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    var userTokenType: String?
    var userAccessToken: String?
    
    func get(from url: URL, userTokenType: String, userAccessToken: String) {
      self.requestedURL = url
      self.userTokenType = userTokenType
      self.userAccessToken = userAccessToken
    }
  }
}
