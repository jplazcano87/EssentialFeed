//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Juan Pablo Lazcano Candia on 22-12-21.
//

import XCTest
import EssentialFeed


class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    
    let (_, client) = makeSUT()
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_load_requestsDataFromURL() {
    let url = URL(string: "https://a-given-url.com")!
    
    let (sut, client) = makeSUT(url: url)
    
    sut.load()
    
    XCTAssertEqual(client.requestedURLs, [url])
  }

  
  func test_loadTwice_requestsDataFromURLTwice() {
    let url = URL(string: "https://a-given-url.com")!
    
    let (sut, client) = makeSUT(url: url)
    
    sut.load()
    sut.load()
   
    XCTAssertEqual(client.requestedURLs, [url, url])
    
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    client.error = NSError(domain: "A Error", code: 0) // property inyection to the client
    //create an array of error, because we can compare the type and the number of times that specific error ocurrs
    var capturedErrors = [RemoteFeedLoader.Error]() // this array is for the capture
    sut.load { capturedErrors.append($0) } // Appends from the closure
    XCTAssertEqual(capturedErrors, [.conectivity])
  }
  
  //Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
  }
  
  private class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    var error: Error?
    func get(from url: URL, completion: @escaping (Error) -> Void) {
      if let error = error {
        completion(error)
      }
      requestedURLs.append(url)
    }
    
  }
  
}
