//
//  HomeModel.swift
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

final class HomeModel: ObservableObject {
    
    // These objects should be provided by dependency injection
    let searchService = PokemonSearchService()
    let dataProvider: DataProvider
    
    @Published var destination: Destination? {
        didSet { self.bind() }
    }
    
    init(destination: Destination? = nil, dataProvider: DataProvider = DataProvider()) {
        self.destination = destination
        self.dataProvider = dataProvider
    }
    
    enum Destination {
        case catchScene(CatchModel)
        case backpackScene(BackpackModel)
    }
    
    func catchButtonTapped() {
        let catchModel = CatchModel(searchService: searchService,
                                            dataProvider: dataProvider)
        destination = .catchScene(catchModel)
    }
    
    func backpackButtonTapped() {
        // dataProvider.start()
        let backpackViewModel = BackpackModel(dataProvider: dataProvider)
        // let pokemons = dataProvider.pokemons()
        // print("Do we have them? \(pokemons.count)")
        destination = .backpackScene(backpackViewModel)
    }
    
    private func bind() {
        switch self.destination {
        case let .catchScene(catchViewModel):
            catchViewModel.onCatchCompleted = { [weak self] in
                guard let self else { return }
                // TODO: save data
                self.destination = nil
                // dataProvider.catchPokemon()
            }
            catchViewModel.onCatchDismissed = { [weak self] in
                guard let self else { return }
                self.destination = nil
            }
            break
        case let .backpackScene(backpackViewModel):
            backpackViewModel.onCancel = { [weak self] in
                guard let self else { return }
                self.destination = nil
            }
            
            break
        case .none:
            break
        }
    }
}
