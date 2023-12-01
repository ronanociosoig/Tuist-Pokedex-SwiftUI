import SwiftUI
import SwiftUINavigation
import XCTestDynamicOverlay
import NukeUI
import os.log
import Common
import NetworkKit

typealias CatchDataProviding = DataSearchProviding & DataProviding & CatchDataProvider

extension AlertState where Action == CatchViewModel.AlertErrorAction {
    static let confirmError = AlertState(title: TextState(Constants.Translations.CatchScene.noPokemonFoundAlertTitle),
                                         message: nil,
                                         buttons: [
                                            .default(TextState(Constants.Translations.ok))
                                         ])
}

final class CatchViewModel: ObservableObject, Notifier {
    
    @Published var destination: Destination?
    @Published var pokemon: ScreenPokemon?
    
    var blockCall: Bool = false
    var dataProvider: CatchDataProviding
    let searchService: SearchService
    
    var onCatchCompleted: () -> Void = unimplemented("CatchViewModel.onCatchCompleted")
    
    init(searchService: SearchService,
         dataProvider: CatchDataProviding,
         destination: Destination? = nil,
         blockCall: Bool = false) {
        self.destination = destination
        self.searchService = searchService
        self.dataProvider = dataProvider
    }
    
    func cancelButtonTapped() {
        os_log("Cancel button tapped", log: Log.general, type: .default)
        self.onCatchCompleted()
    }
    
    func catchButtonTapped() {
        os_log("Catch button tapped", log: Log.general, type: .default)
        dataProvider.catchPokemon()
        self.onCatchCompleted()
    }
    
    enum Destination {
        case loading
        case loaded
        case showErrorAlert(AlertState<AlertErrorAction>)
        case showCatchAlert(AlertState<AlertAction>)
    }
    
    enum AlertAction {
        case catchPokemon
        case leaveIt
    }
    
    enum AlertErrorAction {
        case ok
    }
    
    func showErrorAlert() {
        self.destination = .showErrorAlert(.confirmError)
    }
    
    func showAlertForCatching() {
        let alertTitle = TextState(Constants.Translations.CatchScene.leaveOrCatchAlertMessageTitle)
        let catchItButtonTitle = TextState(Constants.Translations.CatchScene.catchItButtonTitle)
        let cancelButtonTitle = TextState(Constants.Translations.CatchScene.leaveItButtonTitle)
        
        self.destination = .showCatchAlert(
            AlertState(title: alertTitle,
                       message: nil,
                       buttons: [
                        .default(catchItButtonTitle, action: .send(.catchPokemon)),
                        .cancel(cancelButtonTitle)
                       ])
        )
    }
    
    func pokemonHeightString() -> String {
        if let pokemon = pokemon {
            let label = Constants.Translations.CatchScene.height
            return label + " \(pokemon.height)"
        }
        return ""
    }
    
    func pokemonWeightString() -> String {
        if let pokemon = pokemon {
            let label = Constants.Translations.CatchScene.weight
            return label + " \(pokemon.weight)"
        }
        return ""
    }
    
    func searchNextPokemon(identifier: Int?) {
        dataProvider.notifier = self
        
        if blockCall {
            return
        }
        
        let queue = DispatchQueue.global(qos: .background)
        
        if let identifier = identifier {
            dataProvider.search(identifier: identifier, networkService: searchService, queue: queue)
        } else {
            dataProvider.search(identifier: Generator.nextIdentifier(), networkService: searchService, queue: queue)
        }
    }
    
    func dataReceived(errorMessage: String?, on queue: DispatchQueue?) {
        DispatchQueue.main.async {
            os_log("Data received", log: Log.data, type: .default)
            
            // let errorMessage = errorMessage ?? "404"
            
            if let errorMessage = errorMessage, errorMessage.isEmpty {
                os_log("Data error", log: Log.data, type: .default)
                self.showErrorAlert()
            } else {
                self.pokemon = self.dataProvider.pokemon()
                self.showAlertForCatching()
            }
        }
    }
}

struct CatchView: View {
    @ObservedObject var model: CatchViewModel
    
    init(model: CatchViewModel) {
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
                    Spacer().frame(width: 100, height: 200)
                    if let pokemon = model.pokemon {
                        Text(pokemon.name)
                        if let path = pokemon.iconPath, let url = URL(string: path) {
                            LazyImage(url: url)
                        } else {
                            Image("PokemonPlaceholder")
                        }
                        
                    } else {
                        Image("PokemonPlaceholder")
                    }
                    
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
            case: /CatchViewModel.Destination.showCatchAlert
        ) { action in
            if action == .catchPokemon {
                self.model.catchButtonTapped()
            } else {
                self.model.cancelButtonTapped()
            }
        }
        .alert(
            unwrapping: self.$model.destination,
            case: /CatchViewModel.Destination.showErrorAlert
        ) { message in
            
        }
    }
}

struct CatchView_Previews: PreviewProvider {
    static var previews: some View {
        CatchView(model:
                    CatchViewModel(searchService: PokemonSearchService(),
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
