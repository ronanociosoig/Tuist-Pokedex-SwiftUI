//
//  BackpackView.swift
//  Pokedex
//
//  Created by ronan.ociosoig on 16/09/2023.
//  Copyright © 2023 Sonomos.com. All rights reserved.
//

import Common
import SwiftUI
import SwiftUINavigation
import NukeUI
import XCTestDynamicOverlay

final class BackpackViewModel: ObservableObject {
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

struct BackpackView: View {
    @ObservedObject var model: BackpackViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(model.pokemons, id: \.self) { pokemon in
                        Button {
                            model.itemSelected(pokemon: pokemon)
                        } label: {
                            PokedexItemView(pokemon:  pokemon)
                        }
                    }
                }
            }
            .navigationDestination(unwrapping: self.$model.destination, case: /BackpackViewModel.Destination.detail) { $pokemon in
                DetailView(pokemon: pokemon)
            }
        }
    }
}

struct PokedexItemView: View {
    let pokemon: LocalPokemon
    
    var body: some View {
        VStack {
            if let imagePath = pokemon.spriteUrlString, let imageURL = URL(string: imagePath) {
                LazyImage(url: imageURL)
            } else {
                Image("PokemonPlaceholder")
            }
            
            Text(pokemon.name.capitalized)
                .foregroundStyle(.black)
        }
    }
}

struct BackpackView_Previews: PreviewProvider {
    static var previews: some View {
        BackpackView(model: BackpackViewModel(dataProvider: DataProvider()))
    }
}

public protocol BackpackDataProviding {
    func pokemons() -> [LocalPokemon]
}

extension DataProvider: BackpackDataProviding {
    public func pokemons() -> [LocalPokemon] {
        return appData.pokemons
    }
}
