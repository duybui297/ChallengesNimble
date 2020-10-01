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
  private let queue = DispatchQueue(label: "\(CodableSurveysStore.self)Queue",
                                    qos: .userInitiated,
                                    attributes: .concurrent)
  
  public init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  public func retrieve(completion: @escaping RetrievalCompletion) {
    let storeURL = self.storeURL
    queue.async {
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
  }
  
  public func insert(_ surveys: [LocalSurvey],
              timestamp: Date,
              completion: @escaping InsertionCompletion) {
    let storeURL = self.storeURL
    queue.async(flags: .barrier) {
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
  }
  
  public func deleteCachedSurveys(completion: @escaping DeletionCompletion) {
    let storeURL = self.storeURL
    queue.async(flags: .barrier) {
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
}
