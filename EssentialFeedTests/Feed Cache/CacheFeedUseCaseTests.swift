//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Juan Pablo Lazcano Candia on 21-01-22.
//

import XCTest



class FeedStore {
  var deleteCachedFeedCallCount = 0
}

class LocalFeedLoader {
  let store: FeedStore
  init(store: FeedStore) {
    self.store = store
  }
}

class CacheFeedUseCaseTests: XCTestCase {
  func test_init_doesNotDeleteCacheUponCreation() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
  }

}
