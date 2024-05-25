import SwiftUI
import Common

struct DetailView: View {
    let pokemon: LocalPokemon
    
    var body: some View {
        PokemonView(model: PokemonViewModel(pokemon: pokemon))
            .navigationTitle("Pokemon Details")
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(pokemon: MockPokemonFactory.makeLocalPokemon())
    }
}
