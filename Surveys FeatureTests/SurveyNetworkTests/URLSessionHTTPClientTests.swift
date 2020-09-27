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
  
  init(session: URLSession) {
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
  
  func test_getFromURLRequest_createsDataTaskWithURLRequest() {
    let url = URL(string: "http://any-url.com")!
    let userTokenType = "Any User Token Type"
    let userAccessToken = "Any User Access Token"
    
    let session = URLSessionSpy()
    let sut = URLSessionHTTPClient(session: session)
    session.stub(url: url)
    sut.get(from: url,
            userTokenType: userTokenType,
            userAccessToken: userAccessToken) { _ in }
    
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
            userAccessToken: userAccessToken) { _ in }
    
    XCTAssertEqual(task.resumeCallCount, 1)
  }
  
  func test_getFromURLRequest_failsOnRequestError() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let task = URLSessionDataTaskSpy()
    let error = NSError(domain: "any error", code: 1)
    session.stub(url: url, error: error)
    
    let sut = URLSessionHTTPClient(session: session)
    let userTokenType = "Any User Token Type"
    let userAccessToken = "Any User Access Token"
    
    let exp = expectation(description: "Wait for completion")
    
    sut.get(from: url,
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

// MARK: - Spy - stub classes
extension URLSessionHTTPClientTests {
  private class URLSessionSpy: URLSession {
    var receivedURLRequests = [URLRequest]()
    private struct Stub {
      let task: URLSessionDataTask
      let error: Error?
    }
    private var stubs = [URL: Stub]()
    
    func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
      stubs[url] = Stub(task: task, error: error)
    }
    
    override func dataTask(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      
      receivedURLRequests.append(urlRequest)
      guard let stub = stubs[urlRequest.url!] else {
        fatalError("Couln't find stub for \(urlRequest.url)")
      }
      completionHandler(nil, nil, stub.error)
      return stub.task
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
