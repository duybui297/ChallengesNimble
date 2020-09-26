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
    
    expect(sut, toCompleteWithError: .connectivity, when: {
      let clientError = NSError(domain: "any error", code: 0)
      client.complete(with: clientError)
    })
  }
  
  func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    let non200StatusCodes = [199, 201, 300, 400, 401, 404, 403]
    
    non200StatusCodes.enumerated().forEach { index, code in
      expect(sut, toCompleteWithError: .invalidData, when: {
        client.complete(with: code, at: index)
      })
    }
  }
  
  func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
    let (sut, client) = makeSUT()
    
    expect(sut, toCompleteWithError: .invalidData, when: {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(with: 200, data: invalidJSON)
    })
  }
}

// MARK: - Helper functions
extension RemoteSurveyLoaderTests {
  private func makeSUT(url: URL = URL(string: "https://any-url.com")!,
                       userTokenType: String = "Any User Token Type",
                       userAccessToken: String = "Any User Access Token") -> (sut: RemoteSurveyLoader, client: HTTPClientSpy) {
      let client = HTTPClientSpy()
      let sut = RemoteSurveyLoader(httpClient: client,
                                   url: url,
                                   userTokenType: userTokenType,
                                   userAccessToken: userAccessToken)
      return (sut, client)
  }
  
  private func expect(_ sut: RemoteSurveyLoader,
                      toCompleteWithError error: RemoteSurveyLoader.Error,
                      when action: () -> Void,
                      file: StaticString = #file,
                      line: UInt = #line) {
    var capturedErrors = [RemoteSurveyLoader.Error]()
    sut.load { capturedErrors.append($0) }
    
    action()
    
    XCTAssertEqual(capturedErrors, [error], file: file, line: line)
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
    
    var messages = [(requestedInfo: RequestContext, completion: ((HTTPClientResult) -> Void))]()
    
    var requestedInfo: [RequestContext] {
      messages.map(\.requestedInfo)
    }
    
    func get(from url: URL,
             userTokenType: String,
             userAccessToken: String,
             completion: @escaping (HTTPClientResult) -> Void) {
      let requestedInfo = RequestContext(requestedURL: url,
                                         userTokenType: userTokenType,
                                         userAccessToken: userAccessToken)
      self.messages.append((requestedInfo, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      self.messages[index].completion(.failure(error))
    }
    
    func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
      let response = HTTPURLResponse(url: requestedInfo[index].requestedURL,
                                     statusCode: statusCode,
                                     httpVersion: nil,
                                     headerFields: nil)!
      self.messages[index].completion(.success(data, response))
    }
  }
}
