//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Juan Pablo Lazcano Candia on 22-12-21.
//

import Foundation

public final class RemoteFeedLoader {
  
  private let url: URL
  private let client: HTTPClient
  
  public enum Error: Swift.Error {
    case conectivity
    case invalidData
  }
  
  public enum Result: Equatable {
    case sucesss([FeedItem])
    case failure(Error)
  }
  
  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      switch result {
      case let .success(data, response):
        completion(FeedItemMapper.map(data, from: response))
      case .failure:
        completion(.failure(.conectivity))
      }
    }
  }
  
}
