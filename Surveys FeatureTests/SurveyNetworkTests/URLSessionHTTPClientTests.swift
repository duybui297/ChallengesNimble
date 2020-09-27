//
//  URLSessionHTTPClientTests.swift
//  Surveys FeatureTests
//
//  Created by Duy Bui on 9/27/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest

class URLSessionHTTPClient {
  private let session: URLSession

  init(session: URLSession) {
    self.session = session
  }

  func get(from url: URL,
           userTokenType: String,
           userAccessToken: String) {
    let urlRequest = makeURLRequestFrom(from: url,
                                        userTokenType: userTokenType,
                                        userAccessToken: userAccessToken)
    session.dataTask(with: urlRequest) { _, _, _ in }.resume()
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

  func test_getFromURLRequest_createsDataTaskWithURLRequest() {
    let url = URL(string: "http://any-url.com")!
    let userTokenType = "Any User Token Type"
    let userAccessToken = "Any User Access Token"
    
    let session = URLSessionSpy()
    let sut = URLSessionHTTPClient(session: session)

    sut.get(from: url,
            userTokenType: userTokenType,
            userAccessToken: userAccessToken)
    
    let expectedHttpHeaderFields = ["Content-Type": "application/json",
                                   "Authorization": "\(userTokenType) \(userAccessToken)"]

    XCTAssertEqual(session.receivedURLRequests.map(\.url), [url])
    XCTAssertEqual(session.receivedURLRequests.map(\.httpMethod), ["GET"])
    XCTAssertEqual(session.receivedURLRequests.map(\.allHTTPHeaderFields), [expectedHttpHeaderFields])
  }
  
  func test_getFromURLRequest_resumesDataTaskWithURLRequest() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let task = URLSessionDataTaskSpy()
    session.stub(url: url, task: task)
    
    let sut = URLSessionHTTPClient(session: session)
    let userTokenType = "Any User Token Type"
    let userAccessToken = "Any User Access Token"
    sut.get(from: url,
            userTokenType: userTokenType,
            userAccessToken: userAccessToken)
    
    XCTAssertEqual(task.resumeCallCount, 1)
  }
}

// MARK: - Spy - stub classes
extension URLSessionHTTPClientTests {
  private class URLSessionSpy: URLSession {
    var receivedURLRequests = [URLRequest]()

    private var stubs = [URL: URLSessionDataTask]()

    func stub(url: URL, task: URLSessionDataTask) {
      stubs[url] = task
    }
    
    override func dataTask(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      urlRequest.allHTTPHeaderFields
      receivedURLRequests.append(urlRequest)
      return stubs[urlRequest.url!] ?? FakeURLSessionDataTask()
    }
  }
  
  private class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
  }

  private class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeCallCount = 0

    override func resume() {
      resumeCallCount += 1
    }
  }
}
