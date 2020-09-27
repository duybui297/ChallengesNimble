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
    let urlRequest = URLRequest(url: url)
    session.dataTask(with: urlRequest) { _, _, _ in }
  }
}

class URLSessionHTTPClientTests: XCTestCase {

  func test_getFromURL_createsDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let sut = URLSessionHTTPClient(session: session)

    sut.get(from: url,
            userTokenType: "Any User Token Type",
            userAccessToken: "Any User Access Token")

    XCTAssertEqual(session.receivedURLRequests.map(\.url), [url])
  }
}

// MARK: - Spy - stub classes
extension URLSessionHTTPClientTests {
  private class URLSessionSpy: URLSession {
    var receivedURLRequests = [URLRequest]()

    override func dataTask(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      receivedURLRequests.append(urlRequest)
      return FakeURLSessionDataTask()
    }
  }

  private class FakeURLSessionDataTask: URLSessionDataTask {}
}
