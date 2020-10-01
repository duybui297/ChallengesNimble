//
//  CodableSurveysStore.swift
//  SurveysFeature
//
//  Created by Duy Bui on 10/1/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import Foundation

public class CodableSurveysStore: SurveysStore {
  private struct Cache: Codable {
    let surveys: [CodableSurvey]
    let timestamp: Date
    
    var localSurveys: [LocalSurvey] {
      return surveys.map { $0.local }
    }
  }
  
  private let storeURL: URL
  
  public init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  public func retrieve(completion: @escaping RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }
    
    do {
      let decoder = JSONDecoder()
      let cache = try decoder.decode(Cache.self, from: data)
      completion(.found(surveys: cache.localSurveys, timestamp: cache.timestamp))
    } catch {
      completion(.failure(error))
    }
  }
  
  public func insert(_ surveys: [LocalSurvey],
              timestamp: Date,
              completion: @escaping InsertionCompletion) {
    do {
      let encoder = JSONEncoder()
      let cache = Cache(surveys: surveys.map(CodableSurvey.init), timestamp: timestamp)
      let encoded = try encoder.encode(cache)
      try encoded.write(to: storeURL)
      completion(nil)
    } catch {
      completion(error)
    }
  }
  
  public func deleteCachedSurveys(completion: @escaping DeletionCompletion) {
    guard FileManager.default.fileExists(atPath: storeURL.path) else {
      return completion(nil)
    }

    do {
      try FileManager.default.removeItem(at: storeURL)
      completion(nil)
    } catch {
      completion(error)
    }
  }
}
