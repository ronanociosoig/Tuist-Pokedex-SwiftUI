//
//  AppData.swift
//  Common
//
//  Created by Ronan on 09/05/2019.
//  Copyright © 2019 Sonomos. All rights reserved.
//

import Foundation

public protocol AppDataHandling {
    var pokemon: Pokemon? { get set }
    var pokemons: [LocalPokemon] { get set }
    
    func newSpecies() -> Bool
    func load()
    func save()
    func directory() -> Directory
    func sortByOrder()
    func clean()
}

public class AppData: AppDataHandling {
    public static let pokemonFile = "pokemons.json"
    
    public var pokemon: Pokemon?
    public var pokemons = [LocalPokemon]()

    let LocalStorage: Storing.Type
    
    public init(LocalStorage: Storing.Type) {
        self.LocalStorage = LocalStorage
    }
    
    public func newSpecies() -> Bool {
        guard let pokemon = pokemon else { return false }
        
        if pokemons.isEmpty {
            return true
        }
        
        let foundSpecies = pokemons.filter {
            $0.species == pokemon.species.name
        }
        
        return foundSpecies.isEmpty
    }
    
    public func load() {
        let data = LocalStorage.load(AppData.pokemonFile, in: directory())
        let decoder = JSONDecoder()
        do {
            pokemons = try decoder.decode([LocalPokemon].self, from: data)
        } catch {
            fatalError("Failed to decode LocalPokemon array from storage.")
        }
    }
    
    public func save() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(pokemons)
            LocalStorage.save(data, as: AppData.pokemonFile, in: directory())
        } catch {
            fatalError("Failed to save pokemons")
        }
    }
    
    public func clean() {
        LocalStorage.remove(AppData.pokemonFile, in: directory())
    }
    
    public func directory() -> Directory {
        if Configuration.uiTesting {
            return .caches
        }
        return .documents
    }
    
    public func sortByOrder() {
        pokemons.sort(by: {
            $0.order < $1.order
        })
    }
}
