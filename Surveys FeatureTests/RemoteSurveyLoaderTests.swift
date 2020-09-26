//
//  RemoteSurveyLoaderTests.swift
//  Surveys FeatureTests
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import Surveys_Feature

class RemoteSurveyLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURLAndParameters() {
    let url = URL(string: "https://any-url.com")!
    let userTokenType = "Any User Token Type"
    let userAccessToken = "Any User Access Token"
    let client = HTTPClientSpy()
    let _ = RemoteSurveyLoader(httpClient: client,
                               url: url,
                               userTokenType: userTokenType,
                               userAccessToken: userAccessToken)
    XCTAssertTrue(client.requestedInfo.isEmpty)
  }
  
  func test_load_requestDataFromURLAndParameters() {
    let url = URL(string: "https://a-specific-url.com")!
    let userTokenType = "A Specific User Token Type"
    let userAccessToken = "A Specific User Access Token"
    let client = HTTPClientSpy()
    let sut = RemoteSurveyLoader(httpClient: client,
                                 url: url,
                                 userTokenType: userTokenType,
                                 userAccessToken: userAccessToken)
    sut.load()
    XCTAssertEqual(client.requestedInfo, [HTTPClientSpy.RequestContext(requestedURL: url,
                                                                       userTokenType: userTokenType,
                                                                       userAccessToken: userAccessToken)])
  }
  
  func test_loadTwice_requestDataFromURLAndParametersTwice() {
    let url = URL(string: "https://a-specific-url.com")!
    let userTokenType = "A Specific User Token Type"
    let userAccessToken = "A Specific User Access Token"
    let client = HTTPClientSpy()
    let sut = RemoteSurveyLoader(httpClient: client,
                                 url: url,
                                 userTokenType: userTokenType,
                                 userAccessToken: userAccessToken)
    sut.load()
    sut.load()
    
    let expectedRequestContext = HTTPClientSpy.RequestContext(requestedURL: url,
                                                              userTokenType: userTokenType,
                                                              userAccessToken: userAccessToken)
    XCTAssertEqual(client.requestedInfo, [expectedRequestContext, expectedRequestContext])
  }
  
  private class HTTPClientSpy: HTTPClient {
    
    struct RequestContext: Equatable {
      var requestedURL: URL
      var userTokenType: String
      var userAccessToken: String
    }
    
    var requestedInfo = [RequestContext]()
    
    func get(from url: URL, userTokenType: String, userAccessToken: String) {
      self.requestedInfo.append(RequestContext(requestedURL: url,
                                               userTokenType: userTokenType,
                                               userAccessToken: userAccessToken))
    }
  }
}
