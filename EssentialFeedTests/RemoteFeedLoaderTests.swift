//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Juan Pablo Lazcano Candia on 22-12-21.
//

import XCTest


class RemoteFeedLoader {
  
}

class HTTPClient {
  var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
 
  func test_init_doesNotRequestDataFromURL() {
  
    let client = HTTPClient()
  
    _ = RemoteFeedLoader()
    
    XCTAssertNil(client.requestedURL)
  }
}
