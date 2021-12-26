//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Juan Pablo Lazcano Candia on 22-12-21.
//

import Foundation

public struct FeedItem: Equatable {
  let id: UUID
  let description: String?
  let location: String?
  let imageURL: URL
}
