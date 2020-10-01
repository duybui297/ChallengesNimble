//
//  SurveyLoader.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public protocol SurveyLoader {
  typealias Result = Swift.Result<[Survey], Error>
  func load(completion: @escaping (Result) -> Void)
}
