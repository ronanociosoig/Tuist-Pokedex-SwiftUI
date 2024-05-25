//
//  BackpackModel.swift
//  Pokedex
//
//  Created by ronan.ociosoig on 25/05/2024.
//  Copyright © 2024 Sonomos.com. All rights reserved.
//

import Foundation
import Common
import SwiftUI
import SwiftUINavigation
import XCTestDynamicOverlay

final class BackpackModel: ObservableObject {
    @Published var destination: Destination?
    var dataProvider: BackpackDataProviding
    
    var pokemons: [LocalPokemon] {
       // return dataProvider.pokemons().map { convert(pokemon: $0) }
        dataProvider.pokemons()
    }
    
    var onCancel: () -> Void = unimplemented("BackpackViewModel.onCancel")
    
    init(dataProvider: BackpackDataProviding,
         destination: Destination? = nil) {
        self.dataProvider = dataProvider
        self.destination = destination
    }
    
    enum Destination {
        case detail(LocalPokemon)
    }
    
    func itemSelected(pokemon: LocalPokemon) {
        self.destination = .detail(pokemon)
    }
    
    func convert(pokemon: LocalPokemon) -> ScreenPokemon {
        return ScreenPokemon(name: pokemon.name,
                             weight: pokemon.weight, height: pokemon.height, iconPath: pokemon.spriteUrlString)
    }
}
