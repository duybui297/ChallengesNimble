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
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedInfo.isEmpty)
  }
  
  func test_load_requestDataFromURLAndParameters() {
    let url = URL(string: "https://a-specific-url.com")!
    let userTokenType = "A Specific User Token Type"
    let userAccessToken = "A Specific User Access Token"
    
    let (sut, client) = makeSUT(url: url,
                                userTokenType: userTokenType,
                                userAccessToken: userAccessToken)
    
    sut.load { _ in }
    XCTAssertEqual(client.requestedInfo, [HTTPClientSpy.RequestContext(requestedURL: url,
                                                                       userTokenType: userTokenType,
                                                                       userAccessToken: userAccessToken)])
  }
  
  func test_loadTwice_requestDataFromURLAndParametersTwice() {
    let url = URL(string: "https://a-specific-url.com")!
    let userTokenType = "A Specific User Token Type"
    let userAccessToken = "A Specific User Access Token"
    
    let (sut, client) = makeSUT(url: url,
                                userTokenType: userTokenType,
                                userAccessToken: userAccessToken)
    sut.load { _ in }
    sut.load { _ in }
    
    let expectedRequestContext = HTTPClientSpy.RequestContext(requestedURL: url,
                                                              userTokenType: userTokenType,
                                                              userAccessToken: userAccessToken)
    XCTAssertEqual(client.requestedInfo, [expectedRequestContext, expectedRequestContext])
  }
  
  func test_load_deliversConnectivityErrorOnClientError() {
    let (sut, client) = makeSUT()
    
    var capturedErrors = [RemoteSurveyLoader.Error]()
    sut.load { error in
      capturedErrors.append(error)
    }
    
    let clientError = NSError(domain: "any error", code: 0)
    client.complete(with: clientError)
    
    XCTAssertEqual(capturedErrors, [.connectivity])
  }
}

// MARK: - Helper functions
extension RemoteSurveyLoaderTests {
  private func makeSUT(url: URL = URL(string: "https://any-url.com")!,
                       userTokenType: String = "Any User Token Type",
                       userAccessToken: String = "Any User Access Token") -> (sut: RemoteSurveyLoader,
    client: HTTPClientSpy) {
      let client = HTTPClientSpy()
      let sut = RemoteSurveyLoader(httpClient: client,
                                   url: url,
                                   userTokenType: userTokenType,
                                   userAccessToken: userAccessToken)
      return (sut, client)
  }
}

// MARK: - Spy - Stub objects
extension RemoteSurveyLoaderTests {
  private class HTTPClientSpy: HTTPClient {
    
    struct RequestContext: Equatable {
      var requestedURL: URL
      var userTokenType: String
      var userAccessToken: String
    }
    
    var messages = [(requestedInfo: RequestContext, completion: ((Error) -> Void))]()
    
    var requestedInfo: [RequestContext] {
      messages.map(\.requestedInfo)
    }
    
    func get(from url: URL,
             userTokenType: String,
             userAccessToken: String,
             completion: @escaping (Error) -> Void) {
      let requestedInfo = RequestContext(requestedURL: url,
                                         userTokenType: userTokenType,
                                         userAccessToken: userAccessToken)
      self.messages.append((requestedInfo, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      self.messages[index].completion(error)
    }
  }
}
