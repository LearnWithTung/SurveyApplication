//
//  CompositionRoot.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import UIKit
import SurveyFramework

class CompositionRoot {
    private let credentials: Credentials
    private let baseURL: URL
    
    init(baseURL: URL, credentials: Credentials) {
        self.credentials = credentials
        self.baseURL = baseURL
    }
    
    func compose() -> (navController: UINavigationController, flow: Flow) {
        let rootNc = makeInitialNavigationController()
        let store = KeychainTokenStore()
        let client = AlamofireHTTPClient()
        let loginURL = makeLoginURL(from: baseURL)
        let service = RemoteLoginService(url: loginURL, client: client, credentials: credentials, currentDate: Date.init)
        let authenticatedClient = AuthenticatedHTTPClientDecorator(decoratee: client, service: store)
        let surveyURL = makeLoadSurveysURL(from: baseURL)
        
        let mainDelegate = SurveyRequestDelegate(loader: RemoteSurveysLoader(url: surveyURL, client: authenticatedClient))
        let mainFlow = MainFlow(navController: rootNc, delegate: mainDelegate, currentDate: Date.init)
        
        let loginDelegate = LoginRequestDelegate(service: service) { token in
            store.save(token: token) {_ in}
            
        } onError: { error in
            // display error
            
        }

        let authFlow = AuthFlow(navController: rootNc, delegate: loginDelegate)
        
        let flow = AppStartFlow(loader: store, authFlow: authFlow, mainFlow: mainFlow)

        return (rootNc, flow)
    }
    
    private func makeInitialNavigationController() -> UINavigationController {
        let nc = UINavigationController()
        nc.isNavigationBarHidden = true
        
        return nc
    }
    
    private func makeLoginURL(from baseURL: URL) -> URL {
        return baseURL.appendingPathComponent("api/v1/oauth/token")
    }
    
    private func makeLoadSurveysURL(from baseURL: URL) -> URL {
        return baseURL.appendingPathComponent("api/v1/surveys")
    }

}
