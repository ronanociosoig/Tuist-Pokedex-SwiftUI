//
//  DataProvider.swift
//  Common
//
//  Created by Ronan on 09/05/2019.
//  Copyright © 2019 Sonomos. All rights reserved.
//

import Combine
import Foundation
import os.log

public class DataProvider: DataProviding {
    public var appData: AppDataHandling = AppData(StorageType: Storage.self)
    public var notifier: Notifier?
    public var searchCancellable: AnyCancellable?

    public init() {
        
    }
    
    public func start() {
        appData.load()
        appData.sortByOrder()
    }
    
    public func catchPokemon() {
        guard let pokemon = appData.pokemon else { return }
        let localPokemon = PokemonConverter.convert(pokemon: pokemon)
        appData.pokemons.append(localPokemon)
        appData.sortByOrder()
        appData.save()
    }
    
    public func newSpecies() -> Bool {
        return appData.newSpecies()
    }
    
    public func pokemon(at index: Int) -> LocalPokemon {
        return appData.pokemons[index]
    }
    
    public func pokemons() -> [LocalPokemon] {
        return appData.pokemons
    }
}
