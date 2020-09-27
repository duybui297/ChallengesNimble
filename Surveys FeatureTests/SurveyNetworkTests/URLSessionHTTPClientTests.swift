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
    let authorizationValue = "\(userTokenType) \(userAccessToken)"
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue(authorizationValue, forHTTPHeaderField: "Authorization")
     urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    session.dataTask(with: urlRequest) { _, _, _ in }
  }
}

class URLSessionHTTPClientTests: XCTestCase {

  func test_getFromURL_createsDataTaskWithURL() {
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
}

// MARK: - Spy - stub classes
extension URLSessionHTTPClientTests {
  private class URLSessionSpy: URLSession {
    var receivedURLRequests = [URLRequest]()

    override func dataTask(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      urlRequest.allHTTPHeaderFields
      receivedURLRequests.append(urlRequest)
      return FakeURLSessionDataTask()
    }
  }

  private class FakeURLSessionDataTask: URLSessionDataTask {}
}