//
//  CompositionRoot.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import UIKit
import SurveyFramework
import Kingfisher

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
        let tokenLoaderURL = makeTokenLoaderURL(from: baseURL)
        let remoteTokenLoader = RemoteTokenLoader(url: tokenLoaderURL, client: client, credentials: credentials, currentDate: Date.init)
        let tokenLoaderComposite = TokenLoaderComposition(store: store, remoteTokenLoader: remoteTokenLoader, currentDate: Date.init)
        let authenticatedClient = AuthenticatedHTTPClientDecorator(decoratee: client, service: tokenLoaderComposite)
        let surveyURL = makeLoadSurveysURL(from: baseURL)
        
        let surveyDetailFlow = SurveyDetailFlow(navController: rootNc)
        
        let mainDelegate = SurveyRequestDelegate(loader: RemoteSurveysLoader(url: surveyURL, client: authenticatedClient))
        let downloader = ImageDownloader(name: "SurveyImageDownloader")
        let imageLoader = KingfisherImageDataLoader(downloader: downloader)
        let mainFlow: Flow = MainFlow(navController: rootNc, delegate: mainDelegate, imageLoader: imageLoader, currentDate: Date.init, surveyDetailFlow: surveyDetailFlow)
        let mainFlowDecorator = MainQueueDispatchDecorator(decoratee: mainFlow)
        
        let loginDelegate = LoginRequestDelegate(service: service)

        let authFlow = AuthFlow(navController: rootNc, delegate: loginDelegate, store: store)
        
        let authFlowDecorator = MainQueueDispatchDecorator(decoratee: authFlow as Flow)
        
        loginDelegate.onError = {[weak authFlow] _ in
            authFlow?.didLoginWithError("Invalid username or password")
        }
        loginDelegate.onSuccess = authFlow.didLoginSuccess
        
        let flow = AppStartFlow(loader: store, authFlow: authFlowDecorator, mainFlow: mainFlowDecorator)
        authFlow.onLoginSuccess = flow.didLogin

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
    
    private func makeTokenLoaderURL(from baseURL: URL) -> URL {
        return baseURL.appendingPathComponent("api/v1/oauth/token")
    }

}
