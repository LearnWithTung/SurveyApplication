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
        
        let loginDelegate = LoginRequestDelegate(service: service) {[weak store] token in
            store?.save(token: token) {[weak self, weak mainFlow, weak rootNc] result in
                switch result {
                case .success:
                    mainFlow?.start()
                case .failure:
                    guard let navController = rootNc else {return}
                    self?.displayError(message: "Unexpected error. Please try later.", showIn: navController)
                }
            }
        } onError: {[weak self, weak rootNc] _ in
            // display error
            guard let navController = rootNc else {return}
            self?.displayError(message: "Invalid username or password", showIn: navController)
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

    private func displayError(message: String, showIn navController: UINavigationController) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(action)
        navController.present(alertController, animated: true)
    }
}
