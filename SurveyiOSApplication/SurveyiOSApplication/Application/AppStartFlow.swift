//
//  AppStartFlow.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import SurveyFramework

public class AppStartFlow: Flow {
    private let loader: TokenLoader
    private let authFlow: Flow
    private let mainFlow: Flow
    
    public init(loader: TokenLoader, authFlow: Flow, mainFlow: Flow) {
        self.loader = loader
        self.authFlow = authFlow
        self.mainFlow = mainFlow
    }
    
    public func start() {
        loader.load {[weak self] result in
            switch result {
            case .success:
                self?.mainFlow.start()
            case .failure:
                self?.authFlow.start()
            }
        }
    }
    
}
