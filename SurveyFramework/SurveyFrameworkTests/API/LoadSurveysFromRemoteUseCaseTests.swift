//
//  LoadSurveysFromRemoteUseCaseTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest
import SurveyFramework

class LoadSurveysFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedGETURLRequests.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        let query = SurveyQuery(pageNumber: 1, pageSize: 2)
        let expectedURL = makeURL(from: url, query: query)
        
        sut.load(query: query) {_ in}
        
        XCTAssertEqual(client.requestedGETURLRequests.map {$0.url}, [expectedURL])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        let query = SurveyQuery(pageNumber: 1, pageSize: 2)
        let expectedURL = makeURL(from: url, query: query)
        
        sut.load(query: query) {_ in}
        sut.load(query: query) {_ in}

        XCTAssertEqual(client.requestedGETURLRequests.map {$0.url}, [expectedURL, expectedURL])
    }
    
    func test_load_deliversErrorOnClientError() {
        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity) {
            client.completeWithError(clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                let jsonData = makeSurveyJSONData(from: [makeSurveyJSONWith().json])
                client.completeWithStatusCode(code, data: jsonData, at: index)
            }
        }
    }
    
    func test_load_succeedsOn200HTTPResponseEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithSurveys: []) {
            let emptyData = Data("{\"data\": []}".utf8)
            client.completeWithStatusCode(200, data: emptyData)
        }
    }
    
    func test_load_succeedsOn200HTTPResponseListJSON() {
        let (sut, client) = makeSUT()
        
        let item1 = makeSurveyJSONWith(id: UUID())
        let item2 = makeSurveyJSONWith(id: UUID())

        expect(sut, toCompleteWithSurveys: [item1.model, item2.model]) {
            let data = makeSurveyJSONData(from: [item1.json, item2.json])
            client.completeWithStatusCode(200, data: data)
        }
    }
    
    func test_load_doesNotDeliversErrorAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteSurveysLoader? = RemoteSurveysLoader(url: URL(string: "https://a-url.com")!, client: client)
        
        var capturedResult: Result<[Survey], RemoteSurveysLoader.Error>?
        sut?.load(query: anyQuery()) { capturedResult = $0}
        
        sut = nil
        client.completeWithStatusCode(199)
        
        XCTAssertNil(capturedResult)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteSurveysLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteSurveysLoader(url: url, client: client)
        checkForMemoryLeaks(client, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func makeSurvey(id: UUID, title: String, description: String, url: String) -> Survey {
        return Survey(id: id.uuidString,
                            attributes: .init(title: title, description: description, imageURL: url))
    }
    
    private func makeSurveyJSONWith(id: UUID = UUID(), title: String = "any", description: String = "any", url: String = "any") -> (model: Survey, json: [String: Any]) {
        let survey = makeSurvey(id: id, title: title, description: description, url: url)

        let surveyJSON = [
            "id": survey.id,
            "attributes": [
                "title": survey.attributes.title,
                "description": survey.attributes.description,
                "cover_image_url": survey.attributes.imageURL,
            ]
        ] as [String : Any]

        return (survey, surveyJSON)
    }
    
    private func makeSurveyJSONData(from dict: [[String: Any]]) -> Data {
        let json = ["data": dict]

        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteSurveysLoader, toCompleteWithError error: RemoteSurveysLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        var capturedError: RemoteSurveysLoader.Error?
        sut.load(query: anyQuery()) { result in
            switch result {
            case let .failure(error):
                capturedError = error
            default:
                break
            }
            exp.fulfill()
        }
            
        action()
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(capturedError, error, file: file, line: line)
    }
    
    private func expect(_ sut: RemoteSurveysLoader, toCompleteWithSurveys surveys: [Survey], when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        var capturedSurveys: [Survey]?
        sut.load(query: anyQuery()) { result in
            switch result {
            case let .success(surveys):
                capturedSurveys = surveys
            default:
                break
            }
            exp.fulfill()
        }
            
        action()
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(capturedSurveys, surveys, file: file, line: line)
    }
    
    private func anyQuery() -> SurveyQuery {
        return .init(pageNumber: 1, pageSize: 1)
    }
    
    private func makeURL(from url: URL = URL(string: "https://any-url.com")!, query: SurveyQuery = SurveyQuery(pageNumber: 0, pageSize: 0)) -> URL {
        var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponent.queryItems = [
            URLQueryItem(name: "page[number]", value: "\(query.pageNumber)"),
            URLQueryItem(name: "page[size]", value: "\(query.pageSize)")
        ]
        
        return urlComponent.url!
    }

}
