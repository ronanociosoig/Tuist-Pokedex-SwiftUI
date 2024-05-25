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

struct BackpackView: View {
    @ObservedObject var model: BackpackModel
    
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
            .navigationDestination(unwrapping: self.$model.destination, case: /BackpackModel.Destination.detail) { $pokemon in
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
                AsyncImage(url: imageURL)
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
        BackpackView(model: BackpackModel(dataProvider: DataProvider()))
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
