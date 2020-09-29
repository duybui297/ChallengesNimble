//
//  URLSessionHTTPClientTests.swift
//  Surveys FeatureTests
//
//  Created by Duy Bui on 9/27/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class URLSessionHTTPClientTests: XCTestCase {
  override func setUp() {
    super.setUp()
    
    URLProtocolStub.startInterceptingRequests()
  }
  
  override func tearDown() {
    super.tearDown()
    
    URLProtocolStub.stopInterceptingRequests()
  }
  
  func test_getFromURLRequest_perfomrsGETRequestWithURLRequest() {
    let urlRequestInfo = anyURLRequestInfo()
    
    let exp = expectation(description: "Wait for request")
    
    URLProtocolStub.observeRequests { request in
      let expectedHttpHeaderFields = ["Content-Type": "application/json",
                                      "Authorization": "\(urlRequestInfo.userTokenType) \(urlRequestInfo.userAccessToken)"]
      XCTAssertEqual(request.url, urlRequestInfo.url)
      XCTAssertEqual(request.httpMethod, "GET")
      XCTAssertEqual(request.allHTTPHeaderFields, expectedHttpHeaderFields)
      exp.fulfill()
    }
    
    makeSUT().get(from: urlRequestInfo.url,
                  userTokenType: urlRequestInfo.userTokenType,
                  userAccessToken: urlRequestInfo.userAccessToken) { _ in }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURLRequest_failsOnRequestError() {
    let requestError = anyNSError()
    
    let receivedError = receivedErrorWhen(data: nil, response: nil, error: requestError)
    
    XCTAssertEqual(receivedError as NSError?, requestError)
  }
  
  func test_getFromURL_failsOnAllInvalidRepresentationCases() {
    let data = anyData()
    let error = anyNSError()
    let response = anyHTTPURLResponse()
    let nonhttpURLResponse = nonHTTPURLResponse()
    
    XCTAssertNotNil(receivedErrorWhen(data: nil, response: nil, error: nil))
    XCTAssertNotNil(receivedErrorWhen(data: nil, response: nonhttpURLResponse, error: nil))
    XCTAssertNotNil(receivedErrorWhen(data: data, response: nil, error: nil))
    XCTAssertNotNil(receivedErrorWhen(data: data, response: nil, error: error))
    XCTAssertNotNil(receivedErrorWhen(data: nil, response: nonhttpURLResponse, error: error))
    XCTAssertNotNil(receivedErrorWhen(data: nil, response: response, error: error))
    XCTAssertNotNil(receivedErrorWhen(data: data, response: nonhttpURLResponse, error: error))
    XCTAssertNotNil(receivedErrorWhen(data: data, response: response, error: error))
    XCTAssertNotNil(receivedErrorWhen(data: data, response: nonhttpURLResponse, error: nil))
  }
  
  func test_getFromURLRequest_succeedsOnHTTPURLResponseWithData() {
    let data = anyData()
    let response = anyHTTPURLResponse()
    
    let receivedValues = receivedValueWhen(data: data, response: response, error: nil)
    
    XCTAssertEqual(receivedValues?.data, data)
    XCTAssertEqual(receivedValues?.response.url, response.url)
    XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
  }
  
  func test_getFromURLRequest_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
    let response = anyHTTPURLResponse()
    
    let receivedValues = receivedValueWhen(data: nil, response: response, error: nil)

    let emptyData = Data()
    XCTAssertEqual(receivedValues?.data, emptyData)
    XCTAssertEqual(receivedValues?.response.url, response.url)
    XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
  }
}

// MARK: - Important helper functions
extension URLSessionHTTPClientTests {
  private func makeSUT(file: StaticString = #file,
                       line: UInt = #line) -> HTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func receivedValueWhen(data: Data?,
                                 response: URLResponse?,
                                 error: Error?,
                                 file: StaticString = #file,
                                 line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
    let result = receivedResultWhen(data: data,
                                    response: response,
                                    error: error,
                                    file: file,
                                    line: line)
    
    switch result {
    case let .success(data, response):
      return (data, response)
    default:
      XCTFail("Expected success, got \(result) instead", file: file, line: line)
      return nil
    }
  }
  
  private func receivedErrorWhen(data: Data?,
                                 response: URLResponse?,
                                 error: Error?,
                                 file: StaticString = #file,
                                 line: UInt = #line) -> Error? {
    let result = receivedResultWhen(data: data,
                                    response: response,
                                    error: error,
                                    file: file,
                                    line: line)
    
    switch result {
    case let .failure(error):
      return error
    default:
      XCTFail("Expected failure, got \(result) instead", file: file, line: line)
      return nil
    }
  }
  
  private func receivedResultWhen(data: Data?,
                                  response: URLResponse?,
                                  error: Error?,
                                  file: StaticString = #file,
                                  line: UInt = #line) -> HTTPClientResult {
    URLProtocolStub.stub(data: data, response: response, error: error)
    let sut = makeSUT(file: file, line: line)
    let urlRequestInfo = anyURLRequestInfo()
    
    let exp = expectation(description: "Wait for completion")
    
    var receivedResult: HTTPClientResult!
    sut.get(from: urlRequestInfo.url,
         userTokenType: urlRequestInfo.userTokenType,
         userAccessToken: urlRequestInfo.userAccessToken) { result in
          receivedResult = result
          exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
    return receivedResult
  }
  
  private func anyURLRequestInfo() -> (url: URL, userTokenType: String, userAccessToken: String) {
    return (URL(string: "http://any-url.com")!, "Any User Token Type", "Any User Access Token")
  }
  
  private func anyData() -> Data {
    return Data("any data".utf8)
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyHTTPURLResponse() -> HTTPURLResponse {
    return HTTPURLResponse(url: anyURLRequestInfo().url,
                           statusCode: 200,
                           httpVersion: nil,
                           headerFields: nil)!
  }
  
  private func nonHTTPURLResponse() -> URLResponse {
    return URLResponse(url: anyURLRequestInfo().url,
                       mimeType: nil,
                       expectedContentLength: 0,
                       textEncodingName: nil)
  }
}

// MARK: - Spy - stub functions
extension URLSessionHTTPClientTests {
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    private struct Stub {
      let error: Error?
      let data: Data?
      let response: URLResponse?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
      stub = Stub(error: error, data: data, response: response)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
      requestObserver = observer
    }
    
    // MARK: - URLProtocol class
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
      
      if let requestObserver = URLProtocolStub.requestObserver {
        client?.urlProtocolDidFinishLoading(self)
        return requestObserver(request)
      }
      
      if let error = URLProtocolStub.stub?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
      
      if let data = URLProtocolStub.stub?.data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let response = URLProtocolStub.stub?.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
  }
}
