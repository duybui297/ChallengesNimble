//
//  SurveyLoader.swift
//  Surveys Feature
//
//  Created by Duy Bui on 9/26/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public enum SurveyLoaderResult {
  case success([Survey])
  case failure(Error)
}

protocol SurveyLoader {
  func load(completion: @escaping (SurveyLoaderResult) -> Void)
}
