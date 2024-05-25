import SwiftUI
import SwiftUINavigation
import os.log
import Common
import NetworkKit

typealias CatchDataProviding = DataSearchProviding & DataProviding & CatchDataProvider

struct CatchView: View {
    @ObservedObject var model: CatchModel
    
    init(model: CatchModel) {
        self.model = model
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer().frame(width: 100, height: 70)
                    Text(model.pokemon?.name.capitalized ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    AsyncImage(url: model.imageURL) { image in
                        image.resizable()
                    } placeholder: {
                        Image("PokemonPlaceholder")
                    }
                    .frame(width: 200, height: 200)

                    HStack{
                        Spacer()
                        Text(model.pokemonHeightString())
                        Spacer().frame(width: 30)
                        Text(model.pokemonWeightString())
                        Spacer()
                    }
                    
                    Spacer()
                }
                VStack {
                    Spacer()
                        .frame(width: 100, height: 400)
                    Button() {
                        model.catchButtonTapped()
                        
                    } label: {
                        Image("Ball")
                            .resizable()
                            .frame(width: 150, height: 150)
                    }
                    Text("Catch it now!")
                }
            }
        }
        .onAppear {
            model.searchNextPokemon(identifier: nil)
        }
        .alert(
            unwrapping: self.$model.destination,
            case: /CatchModel.Destination.showCatchAlert
        ) { action in
            if action == .catchPokemon {
                self.model.catchButtonTapped()
            } else {
                self.model.cancelButtonTapped()
            }
        }
        .alert(
            unwrapping: self.$model.destination,
            case: /CatchModel.Destination.showErrorAlert
        ) { _ in
            self.model.catchErrorButtonTapped()
        }
    }
    
    
}

struct CatchView_Previews: PreviewProvider {
    static var previews: some View {
        CatchView(model:
                    CatchModel(searchService: PokemonSearchService(),
                                   dataProvider: DataProvider()))
    }
}

public protocol CatchDataProvider {
    func pokemon() -> ScreenPokemon?
    func newSpecies() -> Bool
}

extension DataProvider: CatchDataProvider {
    public func pokemon() -> ScreenPokemon? {
        guard let foundPokemon = appData.pokemon else { return nil }
        return ScreenPokemon(name: foundPokemon.name,
                             weight: foundPokemon.weight,
                             height: foundPokemon.height,
                             iconPath: foundPokemon.sprites.frontDefault)
    }
}
