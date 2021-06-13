//
//  AppStartFlowTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import SurveyiOSApplication
import SurveyFramework

class AppStartFlowTests: XCTestCase {
    
    func test_start_startAuthFlowOnLoadTokenFromStoreFailed() {
        let stub = TokenLoaderStub(stubbedError: anyNSError())
        let (sut, authFlow, mainFlow) = makeSUT(loader: stub)
        
        XCTAssertEqual(authFlow.startCount, 0)
        XCTAssertEqual(mainFlow.startCount, 0)

        sut.start()
        
        XCTAssertEqual(authFlow.startCount, 1)
        XCTAssertEqual(mainFlow.startCount, 0)
    }
    
    func test_start_startMainFlowOnLoadTokenFromStoreSuccess() {
        let stub = TokenLoaderStub(stubbedToken: makeTokenWith(expiredDate: Date()))
        let (sut, authFlow, mainFlow) = makeSUT(loader: stub)
        
        XCTAssertEqual(authFlow.startCount, 0)
        XCTAssertEqual(mainFlow.startCount, 0)

        sut.start()
        
        XCTAssertEqual(authFlow.startCount, 0)
        XCTAssertEqual(mainFlow.startCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(loader: TokenLoaderStub, file: StaticString = #file, line: UInt = #line) -> (sut: AppStartFlow, authFlow: AuthFlowSpy, mainFlow: MainFlowSpy) {
        let authFlow = AuthFlowSpy()
        let mainFlow = MainFlowSpy()
        let sut = AppStartFlow(loader: loader, authFlow: authFlow, mainFlow: mainFlow)
        checkForMemoryLeaks(loader, file: file, line: line)
        checkForMemoryLeaks(authFlow, file: file, line: line)
        checkForMemoryLeaks(mainFlow, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, authFlow, mainFlow)
    }
    
    private class TokenLoaderStub: TokenLoader {
        var stubbedToken: Token?
        var stubbedError: Error?
        
        init(stubbedToken: Token) {
            self.stubbedToken = stubbedToken
        }
        
        init(stubbedError: Error) {
            self.stubbedError = stubbedError
        }
        
        func load(completion: @escaping (Result<Token, Error>) -> Void) {
            if let token = stubbedToken {
                completion(.success(token))
            }
            if let error = stubbedError {
                completion(.failure(error))
            }
        }
    }
    
    private class AuthFlowSpy: Flow {
        var startCount = 0
        
        func start() {
            startCount += 1
        }
    }
    
    private class MainFlowSpy: Flow {
        var startCount = 0
        
        func start() {
            startCount += 1
        }
    }
}
