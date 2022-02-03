//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Juan Pablo Lazcano Candia on 24-01-22.
//

import Foundation

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void

  func deleteCachedFeed(completion: @escaping DeletionCompletion)
  func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}


