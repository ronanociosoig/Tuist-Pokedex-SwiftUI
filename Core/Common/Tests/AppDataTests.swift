//
//  AppDataTests.swift
//  CommonTests
//
//  Created by Ronan O Ciosoig on 26/11/22.
//  Copyright © 2022 Sonomos.com. All rights reserved.
//

import XCTest

@testable import Common

final class AppDataTests: XCTestCase {
    func testNewSpeciesIsFalseWhenNoPokemonDefined() {
        let appData = AppData(StorageType: MockValidStorage.self)
        
        XCTAssertFalse(appData.newSpecies())
    }
    
    func testNewSpeciesIsTrueWhenPokemonDefinedButNoOthers() {
        let appData = AppData(StorageType: MockValidStorage.self)
        appData.pokemon = MockPokemonFactory.makePokemon()
        
        XCTAssertTrue(appData.newSpecies())
    }
    
    func testNewSpeciesIsFalseWhenPokemonsAreEqual() {
        let appData = AppData(StorageType: MockValidStorage.self)
        appData.pokemon = MockPokemonFactory.makePokemon()
        appData.pokemons.append(MockPokemonFactory.makeLocalPokemon())
        
        XCTAssertFalse(appData.newSpecies())
    }
    
    func testSaveAndLoad() {
        let appData = AppData(StorageType: MockValidStorage.self)
        
        XCTAssertTrue(appData.pokemons.isEmpty)
        appData.pokemons.append(MockPokemonFactory.makeLocalPokemon())
        XCTAssertTrue(appData.pokemons.count == 1)
        appData.save()
        appData.pokemons.removeLast()
        XCTAssertTrue(appData.pokemons.isEmpty)
        appData.load()
        XCTAssertTrue(appData.pokemons.count == 1)
        
        // if Storage.fileExists(AppData.pokemonFile, in: .documents) {
         //   Storage.remove(AppData.pokemonFile, from: .documents)
        //}
    }
    
    func testSorting() {
        let expectedName = "cascoon"
        let appData = AppData(StorageType: MockValidStorage.self)
        
        let unsortedPokemons = MockPokemonFactory.makeOutOfOrderLocalPokemons()
        let firstUnsortedPokemon = unsortedPokemons.first
        
        XCTAssertNotEqual(firstUnsortedPokemon?.name, expectedName)
        
        appData.pokemons.append(contentsOf: unsortedPokemons)
        
        appData.sortByOrder()
        
        let firstPokemon = appData.pokemons.first
        
        XCTAssertEqual(firstPokemon?.name, expectedName)
    }
}

struct MockValidStorage: Storing {
    static func fileExists(fileName: String, in directory: Common.Directory) -> Bool {
        return true
    }
    
    static func load(_ fileName: String, in directory: Common.Directory) -> Data {
        let mockPokemon: LocalPokemon = .mock
        let pokemons = [mockPokemon]
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(pokemons)
        } catch {
            fatalError("Failed to encode mock data")
        }
    }
    
    static func save(_ data: Data, as fileName: String, in directory: Common.Directory) {
        
    }

    static func remove(_ fileName: String, in directory: Common.Directory) {
        
    }
}
