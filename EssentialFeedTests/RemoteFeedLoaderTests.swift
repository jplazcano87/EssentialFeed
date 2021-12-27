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
  
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    let samples = [199, 201, 300, 400, 500]
    
    samples.enumerated().forEach { index, code in
      expect(sut, completeWithResult: .failure(.invalidData)) {
        client.complete(withStatusCode: code, at: index)
      }
    }
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    expect(sut, completeWithResult: .failure(.conectivity)) {
      let clientError = NSError(domain: "A Error", code: 0)
      client.complete(with: clientError)
    }
    
  }
  
  func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
    let (sut, client) = makeSUT()
    expect(sut, completeWithResult: .failure(.invalidData)) {
      let invalidJSON = Data("Invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()
    
    expect(sut, completeWithResult: .sucesss([])) {
      let emptyListJSON = Data("{\"items\":[]}".utf8)
      client.complete(withStatusCode: 200, data: emptyListJSON)
    }
  }
  
  func test_load_deliversItemsOn200HTTPResponseWithValirJSONItems() {
    let (sut, client) = makeSUT()
    let item1 = FeedItem(id: UUID(),
                         description: nil,
                         location: nil,
                         imageURL: URL(string: "https://a-url.com")!)
    let item1JSON = [
      "id": item1.id.uuidString,
      "image": item1.imageURL.absoluteString
    ]
    
    let item2 = FeedItem(id: UUID(),
                         description: "a description",
                         location: "a location",
                         imageURL: URL(string: "https://another-url.com")!)
    
    let item2JSON = [
      "id": item2.id.uuidString,
      "description": item2.description,
      "location": item2.location,
      "image": item2.imageURL.absoluteString
    ]
    
    let itemsJSON = [
      "items": [item1JSON, item2JSON]
    ]
    
    expect(sut, completeWithResult: .sucesss([item1, item2])) {
      
      let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
      client.complete(withStatusCode: 200, data: json)
    }
    
  }
  
  //Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
  }
  
  private func expect(_ sut: RemoteFeedLoader, completeWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    
    var capturedResults = [RemoteFeedLoader.Result]() // this array is for the capture
    sut.load { capturedResults.append($0) }
    action()
    XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
      )!
      messages[index].completion(.success(data, response))
      
    }
  }
  
}
