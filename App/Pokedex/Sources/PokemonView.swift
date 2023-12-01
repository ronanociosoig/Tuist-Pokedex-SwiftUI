//
//  PokemonView.swift
//  Pokedex
//
//  Created by ronan.ociosoig on 16/09/2023.
//  Copyright © 2023 Sonomos.com. All rights reserved.
//

import SwiftUI
import Common
import Nuke
import NukeUI

final class PokemonViewModel {
    let pokemon: LocalPokemon
    let formatter = DateFormatter()
    let dateFormat = "dd/mm/yyyy HH:MM"
    
    init(pokemon: LocalPokemon) {
        self.pokemon = pokemon
        formatter.dateFormat = dateFormat
    }
    
    var weight: String {
        "\(Constants.Translations.DetailScene.weight): \(pokemon.weight)"
    }
    
    var height: String {
        "\(Constants.Translations.DetailScene.height): \(pokemon.height)"
    }
    
    var name: String {
        pokemon.name
    }
    
    var imageURL: URL? {
        if let urlString = pokemon.spriteUrlString {
            return URL(string: urlString)
        } else {
            return nil
        }
    }
    
    var baseExperience: String {
        "\(Constants.Translations.DetailScene.experience): \(pokemon.baseExperience)"
    }
    
    var date: String {
        formatter.string(from: pokemon.date)
    }
    
    var types: String {
        var allTypes: String = Constants.Translations.DetailScene.types + ": "
        for type in pokemon.types {
            allTypes.append(type.capitalized)
            allTypes.append(", ")
        }
        return allTypes
    }
}

struct PokemonView: View {
    let model: PokemonViewModel
    
    var body: some View {
        VStack {
            Text(model.name)
            Spacer().frame(width: 10, height: 80)
            LazyImage(url: model.imageURL)
            Spacer().frame(width: 10, height: 40)
            HStack {
                Spacer()
                Text(model.height)
                Spacer()
                Text(model.weight)
                Spacer()
            }
            Spacer().frame(width: 10, height: 20)
            Text(model.baseExperience)
            Text(model.date)
            Text(model.types)
            Spacer()
        }
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonView(model: PokemonViewModel(pokemon: MockPokemonFactory.makeLocalPokemon()))
    }
}
