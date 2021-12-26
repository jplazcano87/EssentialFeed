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
    
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  
  func test_loadTwice_requestsDataFromURLTwice() {
    let url = URL(string: "https://a-given-url.com")!
    
    let (sut, client) = makeSUT(url: url)
    
    sut.load { _ in }
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url, url])
    
  }
  /*
   This test is using a property inyection into the client
   func test_load_deliversErrorOnClientError() {
   let (sut, client) = makeSUT()
   client.error = NSError(domain: "A Error", code: 0)
   //create an array of error, because we can compare the type and the number of times that specific error ocurrs
   var capturedErrors = [RemoteFeedLoader.Error]() // this array is for the capture
   sut.load { capturedErrors.append($0) } // Appends from the closure
   XCTAssertEqual(capturedErrors, [.conectivity])
   }
   */
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    //create an array of error, because we can compare the type and the number of times that specific error ocurrs

   // Appends from the closure
    let samples = [199, 201, 300, 400, 500]
    
    samples.enumerated().forEach { index, code in
      var capturedErrors = [RemoteFeedLoader.Error]() // this array is for the capture
      sut.load { capturedErrors.append($0) }
      client.complete(withStatusCode: code, at: index)
      XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    //create an array of error, because we can compare the type and the number of times that specific error ocurrs
    var capturedErrors = [RemoteFeedLoader.Error]() // this array is for the capture
    sut.load { capturedErrors.append($0) } // Appends from the closure
    
    let clientError = NSError(domain: "A Error", code: 0)
    
    client.complete(with: clientError)
    XCTAssertEqual(capturedErrors, [.conectivity])
  }
  
  //Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
  }
  
  private class HTTPClientSpy: HTTPClient {
    //array of tuple to capture both urls and completion
    private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    // computed properties that fills with only the urls from the tuples array
    var requestedURLs: [URL] {
      return messages.map {
        $0.url
      }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
      )!
      messages[index].completion(.success(response))
      
    }
  }
  
}
