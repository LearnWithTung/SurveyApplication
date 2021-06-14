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
    
    func test_didLogin_startsMainFlow() {
        let stub = TokenLoaderStub(stubbedToken: makeTokenWith(expiredDate: Date()))
        let (sut, _, mainFlow) = makeSUT(loader: stub)
        
        sut.didLogin()
        
        XCTAssertEqual(mainFlow.startCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(loader: TokenLoaderStub, file: StaticString = #file, line: UInt = #line) -> (sut: AppStartFlow, authFlow: FlowTests, mainFlow: FlowTests) {
        let authFlow = FlowTests()
        let mainFlow = FlowTests()
        let sut = AppStartFlow(loader: loader, authFlow: authFlow, mainFlow: mainFlow)
        checkForMemoryLeaks(loader, file: file, line: line)
        checkForMemoryLeaks(authFlow, file: file, line: line)
        checkForMemoryLeaks(mainFlow, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, authFlow, mainFlow)
    }
    
}
