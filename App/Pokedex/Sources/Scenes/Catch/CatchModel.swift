//
//  CatchModel.swift
//  Pokedex
//
//  Created by ronan.ociosoig on 25/05/2024.
//  Copyright © 2024 Sonomos.com. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUINavigation
import Common
import NetworkKit
import os.log
import XCTestDynamicOverlay

extension AlertState where Action == CatchModel.AlertErrorAction {
    static let confirmError = AlertState(title: TextState(Constants.Translations.CatchScene.noPokemonFoundAlertTitle),
                                         message: nil,
                                         buttons: [
                                            .default(TextState(Constants.Translations.ok))
                                         ])
    static func networkError(message: String) -> AlertState {
        AlertState(title: TextState("Network Error"),
                   message: TextState(message),
                   buttons: [
                    .default(TextState(Constants.Translations.ok))
                   ])
    }
}

final class CatchModel: ObservableObject, Notifier {
    
    @Published var destination: Destination?
    @Published var pokemon: ScreenPokemon?
    @Published var imageURL: URL?
    
    var blockCall: Bool = false
    var dataProvider: CatchDataProviding
    let searchService: SearchService
    
    var onCatchCompleted: () -> Void = unimplemented("CatchViewModel.onCatchCompleted")
    var onCatchDismissed: () -> Void = unimplemented("CatchViewModel.onCatchDismissed")
    
    init(searchService: SearchService,
         dataProvider: CatchDataProviding,
         destination: Destination? = nil,
         blockCall: Bool = false) {
        self.destination = destination
        self.searchService = searchService
        self.dataProvider = dataProvider
        self.blockCall = blockCall
    }
    
    func cancelButtonTapped() {
        os_log("Cancel button tapped", log: Log.general, type: .default)
        self.onCatchDismissed()
    }
    
    func catchButtonTapped() {
        os_log("Catch button tapped", log: Log.general, type: .default)
        dataProvider.catchPokemon()
        self.onCatchCompleted()
    }
    
    func catchErrorButtonTapped() {
        self.onCatchDismissed()
    }
    
    enum Destination {
        case loading
        case loaded
        case showErrorAlert(AlertState<AlertErrorAction>)
        case showCatchAlert(AlertState<AlertAction>)
    }
    
    enum AlertAction {
        case catchPokemon
        case leaveIt
    }
    
    enum AlertErrorAction {
        case ok
        case networkError(message: String)
    }
    
    func showErrorAlert(message: String?) {
        if let message = message {
            self.destination = .showErrorAlert(.networkError(message: message))
        } else {
            self.destination = .showErrorAlert(.confirmError)
        }
    }
    
    func showAlertForCatching() {
        let alertTitle = TextState(Constants.Translations.CatchScene.leaveOrCatchAlertMessageTitle)
        let catchItButtonTitle = TextState(Constants.Translations.CatchScene.catchItButtonTitle)
        let cancelButtonTitle = TextState(Constants.Translations.CatchScene.leaveItButtonTitle)
        
        self.destination = .showCatchAlert(
            AlertState(title: alertTitle,
                       message: nil,
                       buttons: [
                        .default(catchItButtonTitle, action: .send(.catchPokemon)),
                        .cancel(cancelButtonTitle)
                       ])
        )
    }
    
    func pokemonHeightString() -> String {
        if let pokemon = pokemon {
            let label = Constants.Translations.CatchScene.height
            return label + " \(pokemon.height)"
        }
        return ""
    }
    
    func pokemonWeightString() -> String {
        if let pokemon = pokemon {
            let label = Constants.Translations.CatchScene.weight
            return label + " \(pokemon.weight)"
        }
        return ""
    }
    
    func searchNextPokemon(identifier: Int?) {
        dataProvider.notifier = self
        
        if blockCall {
            return
        }
        
        let queue = DispatchQueue.global(qos: .background)
        
        if let identifier = identifier {
            dataProvider.search(identifier: identifier, networkService: searchService, queue: queue)
        } else {
            dataProvider.search(identifier: Generator.nextIdentifier(), networkService: searchService, queue: queue)
        }
    }
    
    func dataReceived(errorMessage: String?, on queue: DispatchQueue?) {
        
        
        DispatchQueue.main.async {
            os_log("Data received", log: Log.data, type: .default)
            
            if let errorMessage = errorMessage {
                if errorMessage.isEmpty {
                    os_log("Data error", log: Log.data, type: .default)
                    self.showErrorAlert(message: nil)
                } else {
                    os_log("Network error", log: Log.data, type: .default)
                    self.showErrorAlert(message: errorMessage)
                }
                
            } else {
                self.pokemon = self.dataProvider.pokemon()
                
                if let path = self.pokemon?.iconPath {
                    self.imageURL = URL(string: path)
                }
                
                self.showAlertForCatching()
            }
        }
    }
}
