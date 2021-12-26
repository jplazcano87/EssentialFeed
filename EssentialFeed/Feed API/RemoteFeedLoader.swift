//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Juan Pablo Lazcano Candia on 22-12-21.
//

import Foundation

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
  
  private let url: URL
  private let client: HTTPClient
  
  public enum Error: Swift.Error {
    case conectivity
    case invalidData
  }
  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Error) -> Void) {
    client.get(from: url) { error, response in
      if let _ = response {
        completion(.invalidData)
      } else {
        completion(.conectivity)
      }
    }
  }
  
}



