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
    
    expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
      let clientError = NSError(domain: "any error", code: 0)
      client.complete(with: clientError)
    })
  }
  
  func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    let non200StatusCodes = [199, 201, 300, 400, 401, 404, 403]
    
    non200StatusCodes.enumerated().forEach { index, code in
      expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
        client.complete(with: code, at: index)
      })
    }
  }
  
  func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
    let (sut, client) = makeSUT()
    
    expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(with: 200, data: invalidJSON)
    })
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()

    var capturedResults = [RemoteSurveyLoader.Result]()
    sut.load { capturedResults.append($0) }

    let emptyListJSON = Data("{\"data\": []}".utf8)
    client.complete(with: 200, data: emptyListJSON)

    XCTAssertEqual(capturedResults, [.success([])])
  }
  
  func test_load_deliversSurveyItemsOn200HTTPResponseWithJSONItems() {
    let (sut, client) = makeSUT()

    let firstItem = makeSurveyItem(id: UUID(),
                               type: "the first type",
                               title: "the first title",
                               description: "the first description",
                               isActive: true,
                               coverImageURL: URL(string: "http://the-first.com")!,
                               createdAt: "the first day",
                               activeAt: "the first created day",
                               surveyType: "the first survey day")
    
    let secondItem = makeSurveyItem(id: UUID(),
                               type: "the second type",
                               title: "the second title",
                               description: "the second description",
                               thankEmailAboveThreshold: "thank email above",
                               thankEmailBelowThreshold: "thank email below",
                               isActive: false,
                               coverImageURL: URL(string: "http://the-second.com")!,
                               createdAt: "the second day",
                               activeAt: "the second created day",
                               surveyType: "the second survey day")

    let surveyItemsJSON = [
      "items": [firstItem.json, secondItem.json]
    ]

    expect(sut,
           toCompleteWithResult: .success([firstItem.model, secondItem.model]), when: {
      let json = try! JSONSerialization.data(withJSONObject: surveyItemsJSON)
      client.complete(with: 200, data: json)
    })
  }

}

// MARK: - Important helper functions
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
                      toCompleteWithResult result: RemoteSurveyLoader.Result,
                      when action: () -> Void,
                      file: StaticString = #file,
                      line: UInt = #line) {
    var capturedErrors = [RemoteSurveyLoader.Result]()
    sut.load { capturedErrors.append($0) }
    
    action()
    
    XCTAssertEqual(capturedErrors, [result], file: file, line: line)
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

// MARK: - Generating mocking helper functions
extension RemoteSurveyLoaderTests {
  private func makeSurveyItem(id: UUID,
                              type: String,
                              title: String,
                              description: String,
                              thankEmailAboveThreshold: String? = nil,
                              thankEmailBelowThreshold: String? = nil,
                              isActive: Bool,
                              coverImageURL: URL,
                              createdAt: String,
                              activeAt: String,
                              inactiveAt: String? = nil,
                              surveyType: String) -> (model: SurveyItem, json: [String: Any]) {
    let surveyAttributes = SurveyAttribute(title: title,
                                           description: description,
                                           thankEmailAboveThreshold: thankEmailAboveThreshold,
                                           thankEmailBelowThreshold: thankEmailBelowThreshold,
                                           isActive: isActive,
                                           coverImageURL: coverImageURL,
                                           createdAt: createdAt,
                                           activeAt: activeAt,
                                           inactiveAt: inactiveAt,
                                           surveyType: surveyType)
    
    let jsonSurveyAttributes: [String: Any] = ["title": title,
                                "description": description,
                                "thank_email_above_threshold": thankEmailAboveThreshold,
                                "thank_email_below_threshold": thankEmailBelowThreshold,
                                "is_active": isActive,
                                "cover_image_url": coverImageURL,
                                "created_at": createdAt,
                                "active_at": activeAt,
                                "inactive_at": inactiveAt,
                                "survey_type": surveyType
                              ].compactMapValues { $0 }
    
    let uuidString = id.uuidString
    let surveyItem = SurveyItem(id: uuidString,
                                type: type,
                                attributes: surveyAttributes)
    
    let jsonSurveyItem = ["id": uuidString,
                          "type": type,
                          "attributes": jsonSurveyAttributes
                          ].compactMapValues { $0 }
    
    
    return (surveyItem, jsonSurveyItem)
  }

  private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["data": items]
    return try! JSONSerialization.data(withJSONObject: json)
  }
}
