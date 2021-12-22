//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Juan Pablo Lazcano Candia on 22-12-21.
//

import Foundation

public protocol HTTPClient {
  func get(from url: URL)
}

public final class RemoteFeedLoader {
  
  private let url: URL
  private let client: HTTPClient
 
  public enum Error: Swift.Error {
    case conectivity
  }
  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: (Error) -> Void = { _ in }) {
    client.get(from: url)
  }
  
}



