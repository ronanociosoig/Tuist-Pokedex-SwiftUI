import SwiftUI
import SwiftUINavigation
import XCTestDynamicOverlay
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
    static func networkError(message: String) -> AlertState {
        AlertState(title: TextState("Network Error"),
                   message: TextState(message),
                   buttons: [
                    .default(TextState(Constants.Translations.ok))
                   ])
    }
}

final class CatchViewModel: ObservableObject, Notifier {
    
    @Published var destination: Destination?
    @Published var pokemon: ScreenPokemon?
    @Published var imageURL: URL?
    
    var blockCall: Bool = false
    var dataProvider: CatchDataProviding
    let searchService: SearchService
    
    var onCatchCompleted: () -> Void = unimplemented("CatchViewModel.onCatchCompleted")
    var onCatchDismissed: () -> Void = unimplemented("CatchViewModel.onCatchDismissed")
    
    init(searchService: SearchService,
         dataProvider: CatchDataProviding,
         destination: Destination? = nil,
         blockCall: Bool = false) {
        self.destination = destination
        self.searchService = searchService
        self.dataProvider = dataProvider
        self.blockCall = blockCall
    }
    
    func cancelButtonTapped() {
        os_log("Cancel button tapped", log: Log.general, type: .default)
        self.onCatchDismissed()
    }
    
    func catchButtonTapped() {
        os_log("Catch button tapped", log: Log.general, type: .default)
        dataProvider.catchPokemon()
        self.onCatchCompleted()
    }
    
    func catchErrorButtonTapped() {
        self.onCatchDismissed()
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
        case networkError(message: String)
    }
    
    func showErrorAlert(message: String?) {
        if let message = message {
            self.destination = .showErrorAlert(.networkError(message: message))
        } else {
            self.destination = .showErrorAlert(.confirmError)
        }
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
            
            if let errorMessage = errorMessage {
                if errorMessage.isEmpty {
                    os_log("Data error", log: Log.data, type: .default)
                    self.showErrorAlert(message: nil)
                } else {
                    os_log("Network error", log: Log.data, type: .default)
                    self.showErrorAlert(message: errorMessage)
                }
                
            } else {
                self.pokemon = self.dataProvider.pokemon()
                
                if let path = self.pokemon?.iconPath {
                    self.imageURL = URL(string: path)
                }
                
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
        ) { _ in
            self.model.catchErrorButtonTapped()
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
