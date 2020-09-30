//
//  Surveys_FeatureAPIEndToEndTests.swift
//  Surveys_FeatureAPIEndToEndTests
//
//  Created by Duy Bui on 9/28/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import XCTest
import SurveysFeature

class Surveys_FeatureAPIEndToEndTests: XCTestCase {
  
  func test_endToEndTestServerGETSurveyResult_matchesFixedTestAccountData() {
    switch getSurveyResult() {
    case let .success(surveys)?:
      XCTAssertEqual(surveys.count, 5, "Expected 5 surveys in the test account survey")
      XCTAssertEqual(surveys[0], expectedSurvey(at: 0))
      XCTAssertEqual(surveys[1], expectedSurvey(at: 1))
      XCTAssertEqual(surveys[2], expectedSurvey(at: 2))
      XCTAssertEqual(surveys[3], expectedSurvey(at: 3))
      XCTAssertEqual(surveys[4], expectedSurvey(at: 4))
      
    case let .failure(error)?:
      XCTFail("Expected successful survey result, got \(error) instead")
      
    default:
      XCTFail("Expected successful survey result, got no result instead")
    }
  }
  
  // MARK: - Helpers
  private func getSurveyResult(file: StaticString = #file, line: UInt = #line) -> SurveyLoaderResult? {
    let testServerURL = URL(string: "https://nimble-survey-web-staging.herokuapp.com/api/v1/surveys")!
    let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    let loader = RemoteSurveyLoader(httpClient: client,
                                    url: testServerURL,
                                    userTokenType: "Bearer",
                                    userAccessToken: "J7hDJGqm8XI0waHKNOWmABX0z4smZrfl3NMmDi2LWr8")
    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(loader, file: file, line: line)
    
    let exp = expectation(description: "Wait for load completion")

    var receivedResult: SurveyLoaderResult?
    loader.load { result in
      receivedResult = result
      exp.fulfill()
    }
    wait(for: [exp], timeout: 5.0)

    return receivedResult
  }
  
  private func expectedSurvey(at index: Int) -> Survey {
    let surveyAttribute = SurveyAttribute(title: title(at: index),
                                          description: description(at: index),
                                          thankEmailAboveThreshold: thankEmailAbove(at: index),
                                          thankEmailBelowThreshold: thankEmailBelow(at: index),
                                          isActive: true,
                                          coverImageURL: imageURL(at: index),
                                          createdAt: createdAt(at: index),
                                          activeAt: activeAt(at: index),
                                          inactiveAt: nil,
                                          surveyType: surveyType(at: index))
    return Survey(id: id(at: index),
                      type: "survey",
                      attributes: surveyAttribute)
  }
  
  private func id(at index: Int) -> String {
    return [
      "d5de6a8f8f5f1cfe51bc",
      "ed1d4f0ff19a56073a14",
      "270130035d415c1d90bb",
      "a83d91f5518e5c14a8bf",
      "5d2538f53ca50536292c"
      ][index]
  }
  
  private func title(at index: Int) -> String {
    return [
      "Scarlett Bangkok",
      "ibis Bangkok Riverside",
      "21 on Rajah",
      "Let's Chick",
      "Health Land Spa"
      ][index]
  }
  
  private func description(at index: Int) -> String {
    return [
      "We'd love ot hear from you!",
      "We'd love to hear from you!",
      "We'd love to hear from you!",
      "We'd love to hear from you!",
      "We'd love to hear from you!"
      ][index]
  }
  
  private func thankEmailAbove(at index: Int) -> String? {
    return [
      "<span style=\"font-family:arial,helvetica,sans-serif\"><span style=\"font-size:14px\">Dear {name},<br /><br />Thank you for visiting Scarlett Wine Bar &amp; Restaurant at Pullman Bangkok Hotel G &nbsp;and for taking the time to complete our guest feedback survey!<br /><br />Your feedback is very important to us and each survey is read individually by the management and owners shortly after it is sent. We discuss comments and suggestions at our daily meetings and use them to constantly improve our services.<br /><br />We would very much appreciate it if you could take a few more moments and review us on TripAdvisor regarding your recent visit. By <a href=\"https://www.tripadvisor.com/Restaurant_Review-g293916-d2629404-Reviews-Scarlett_Wine_Bar_Restaurant-Bangkok.html\">clicking here</a> you will be directed to our page.&nbsp;<br /><br />Thank you once again and we look forward to seeing you soon!<br /><br />The Team at Scarlett Wine Bar &amp; Restaurant&nbsp;</span></span><span style=\"font-family:arial,helvetica,sans-serif; font-size:14px\">Pullman Bangkok Hotel G</span>",
      "Dear {name},<br /><br />Thank you for visiting Beach Republic and for taking the time to complete our brief survey. We are thrilled that you enjoyed your time with us! If you have a moment, we would be greatly appreciate it if you could leave a short review on <a href=\"http://www.tripadvisor.com/Hotel_Review-g1188000-d624070-Reviews-Beach_Republic_The_Residences-Lamai_Beach_Maret_Ko_Samui_Surat_Thani_Province.html\">TripAdvisor</a>. It helps to spread the word and let others know about the Beach Republic Revolution!<br /><br />Thank you again and we look forward to welcoming you back soon.<br /><br />Sincerely,<br /><br />Beach Republic Team",
      nil,
      "<div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Dear {name},</span></span></div><div>&nbsp;</div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Thank you for visiting Bei Otto and taking the time to complete our brief survey. We constantly strive to improve our guests&#39; experience and your essential feedback will go a long way in helping us achieve our aim. Each and every survey is read carefully and discussed by our team in daily meetings.</span></span></div><div>&nbsp;</div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">We would deeply appreciate it if you would be willing to share some recommendations from our menu, the service you received from our team and some memorable pictures of your meal on TripAdvisor by <a href=\"https://www.tripadvisor.com/Restaurant_Review-g293916-d833538-Reviews-Bei_Otto-Bangkok.html\">clicking here</a> ; you will then be directed to our page.&nbsp;</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">&nbsp;</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">We are looking forward to welcoming you again to Bei Otto hopefully in the very near future.</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">&nbsp;</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Warm regards,</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Bei Otto</span></span></div><br />&nbsp;",
      nil
      ][index]
  }
  
  private func thankEmailBelow(at index: Int) -> String? {
    return [
      "<span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Dear {name},<br /><br />Thank you for visiting&nbsp;</span></span><span style=\"font-family:arial,helvetica,sans-serif; font-size:14px\">Uno Mas at Centara Central World&nbsp;</span><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">&nbsp;and for taking the time to complete our customer&nbsp;feedback survey.</span></span><br /><br /><span style=\"font-family:arial,helvetica,sans-serif; font-size:14px\">The Team at&nbsp;</span><span style=\"font-family:arial,helvetica,sans-serif\"><span style=\"font-size:14px\">Scarlett Wine Bar &amp; Restaurant&nbsp;</span></span><span style=\"font-family:arial,helvetica,sans-serif; font-size:14px\">Pullman Bangkok Hotel G</span>",
      "Dear {name},<br /><br />Thank you for visiting Beach Republic and for taking the time to complete our brief survey. We are constantly striving to improve and your feedback allows us to help improve the experience for you on your next visit. Each survey is read individually by senior staff and discussed with the team in daily meetings.&nbsp;<br /><br />Thank you again and we look forward to welcoming you back soon.<br /><br />Sincerely,<br /><br />Beach Republic Team",
      nil,
      "<div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Dear {name},</span></span></div><div>&nbsp;</div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Thank you for visiting Bei Otto and for taking the time to complete our brief survey.&nbsp;</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">&nbsp;</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">We would like to sincerely apologise that we failed to delight you while dining with us and truly regret that you found our service not up to our usual high standards. Your comments on your survey have been well noted and will be shared with our team for immediate improvement as we consider the points you raised to be one of our priorities. Please do not hesitate to share more details of your dining experience directly &nbsp;with me via info@beiotto.com so as we can improve our services for your next visit.&nbsp;</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">&nbsp;</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">We hope you will give us another chance to show you a true Bei Otto experience in hopefully the not too distant future.</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">&nbsp;</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Sincerely,</span></span></div><div><span style=\"font-size:14px\"><span style=\"font-family:arial,helvetica,sans-serif\">Bei Otto</span></span></div><div>&nbsp;</div>",
      nil
      ][index]
  }
  
  private func imageURL(at index: Int) -> URL {
    return [URL(string: "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_"),
            URL(string: "https://dhdbhh0jsld0o.cloudfront.net/m/287db81c5e4242412cc0_"),
            URL(string: "https://dhdbhh0jsld0o.cloudfront.net/m/0221e768b99dc3576210_"),
            URL(string: "https://dhdbhh0jsld0o.cloudfront.net/m/6ea42840403875928db3_"),
            URL(string: "https://dhdbhh0jsld0o.cloudfront.net/m/59e9e7327354006c1ebc_")
    ][index]!
  }
  
  private func createdAt(at index: Int) -> String {
    return [
      "2017-01-23T07:48:12.991Z",
      "2017-01-23T03:32:24.585Z",
      "2017-01-20T10:08:42.531Z",
      "2017-01-19T06:03:42.220Z",
      "2017-01-18T09:13:55.081Z"
      ][index]
  }
  
  private func activeAt(at index: Int) -> String {
    return [
      "2015-10-08T07:04:00.000Z",
      "2016-01-22T04:12:00.000Z",
      "2017-01-20T10:08:42.512Z",
      "2016-12-15T02:39:00.000Z",
      "2017-01-18T09:13:00.000Z"
      ][index]
  }
  
  private func surveyType(at index: Int) -> String {
    return [
      "Restaurant",
      "Hotel",
      "Restaurant",
      "Restaurant",
      "Wellness"
      ][index]
  }
  
}
