//
//  Mocks.swift
//  CommonTests
//
//  Created by Ronan O Ciosoig on 26/11/22.
//  Copyright © 2022 Sonomos.com. All rights reserved.
//

import UIKit

@testable import Common

class MockAppData: AppDataHandling {
    var pokemon: Common.Pokemon?
    var pokemons = [LocalPokemon]()
    
    var newSpeciesCalled = false
    var loadCalled = false
    var saveCalled = false
    var sortByOrderCalled = false
    
    init() {
        
    }
    
    func newSpecies() -> Bool {
        newSpeciesCalled = true
        return true
    }
    
    func load() {
        loadCalled = true
    }
    
    func save() {
        saveCalled = true
    }
    
    func directory() -> Common.Directory {
        return .documents
    }
    
    func sortByOrder() {
        sortByOrderCalled = true
    }
    
    func clean() {
        
    }
}
