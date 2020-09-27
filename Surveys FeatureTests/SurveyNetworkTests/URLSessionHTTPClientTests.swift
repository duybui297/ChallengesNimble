//
//  URLSessionHTTPClientTests.swift
//  Surveys FeatureTests
//
//  Created by Duy Bui on 9/27/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import Surveys_Feature

class URLSessionHTTPClient {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  func get(from url: URL,
           userTokenType: String,
           userAccessToken: String,
           completion: @escaping (HTTPClientResult) -> Void) {
    let urlRequest = makeURLRequestFrom(from: url,
                                        userTokenType: userTokenType,
                                        userAccessToken: userAccessToken)
    session.dataTask(with: urlRequest) { _, _, error in
      if let error = error {
        completion(.failure(error))
      }
    }.resume()
  }
  
  private func makeURLRequestFrom(from url: URL,
                                  userTokenType: String,
                                  userAccessToken: String) -> URLRequest {
    let authorizationValue = "\(userTokenType) \(userAccessToken)"
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue(authorizationValue, forHTTPHeaderField: "Authorization")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return urlRequest
  }
}

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
    let url = URL(string: "http://any-url.com")!
    let userTokenType = "Any User Token Type"
    let userAccessToken = "Any User Access Token"
    
    let exp = expectation(description: "Wait for request")
    
    URLProtocolStub.observeRequests { request in
      let expectedHttpHeaderFields = ["Content-Type": "application/json",
                                      "Authorization": "\(userTokenType) \(userAccessToken)"]
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")
      XCTAssertEqual(request.allHTTPHeaderFields, expectedHttpHeaderFields)
      exp.fulfill()
    }
    
    makeSUT().get(from: url,
            userTokenType: userTokenType,
            userAccessToken: userAccessToken) { _ in }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURLRequest_failsOnRequestError() {
    let url = URL(string: "http://any-url.com")!
    let userTokenType = "Any User Token Type"
    let userAccessToken = "Any User Access Token"
    
    let error = NSError(domain: "any error", code: 1)
    URLProtocolStub.stub(data: nil, response: nil, error: error)
    
    let exp = expectation(description: "Wait for completion")
    
    makeSUT().get(from: url,
            userTokenType: userTokenType,
            userAccessToken: userAccessToken) { result in
              switch result {
              case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
              default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
              }
              
              exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
}

// MARK: - Important helper functions
extension URLSessionHTTPClientTests {
  private func makeSUT() -> URLSessionHTTPClient {
    return URLSessionHTTPClient()
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
      requestObserver?(request)
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
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
