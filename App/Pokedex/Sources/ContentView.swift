import SwiftUI
import SwiftUINavigation
import Common
import NetworkKit

final class ContentViewModel: ObservableObject {
    
    // These objects should be provided by dependency injection
    let searchService = PokemonSearchService()
    let dataProvider: DataProvider
    
    @Published var destination: Destination? {
        didSet { self.bind() }
    }
    
    init(destination: Destination? = nil, dataProvider: DataProvider = DataProvider()) {
        self.destination = destination
        self.dataProvider = dataProvider
    }
    
    enum Destination {
        case catchScene(CatchViewModel)
        case backpackScene(BackpackViewModel)
    }
    
    func catchButtonTapped() {
        let catchViewModel = CatchViewModel(searchService: searchService,
                                            dataProvider: dataProvider)
        destination = .catchScene(catchViewModel)
    }
    
    func backpackButtonTapped() {
        // dataProvider.start()
        let backpackViewModel = BackpackViewModel(dataProvider: dataProvider)
        // let pokemons = dataProvider.pokemons()
        // print("Do we have them? \(pokemons.count)")
        destination = .backpackScene(backpackViewModel)
    }
    
    private func bind() {
        switch self.destination {
        case let .catchScene(catchViewModel):
            catchViewModel.onCatchCompleted = { [weak self] in
                guard let self else { return }
                // TODO: save data
                self.destination = nil
                // dataProvider.catchPokemon()
            }
            catchViewModel.onCatchDismissed = { [weak self] in
                guard let self else { return }
                self.destination = nil
            }
            break
        case let .backpackScene(backpackViewModel):
            backpackViewModel.onCancel = { [weak self] in
                guard let self else { return }
                self.destination = nil
            }
            
            break
        case .none:
            break
        }
    }
}

struct ContentView: View {
    @ObservedObject var model: ContentViewModel
    
    init(contentViewModel: ContentViewModel) {
        self.model = contentViewModel
    }
    
    var body: some View {
        VStack {
            Spacer()
            Button() {
                model.catchButtonTapped()
            } label: {
                
                Image("Ball")
                    .resizable()
                    .frame(width: 150, height: 150)
            }
            Text("Catch")
            Spacer()
            Button() {
                model.backpackButtonTapped()
            } label: {
                Image("Backpack")
                    .resizable()
                    .frame(width: 150, height: 150)
                
            }
            Text("Backpack")
            Spacer()
        }
        .padding()
        .sheet(unwrapping: self.$model.destination,
               case: /ContentViewModel.Destination.backpackScene,
               content: { $backpackViewModel in
            NavigationStack {
                BackpackView(model: backpackViewModel)
                    .navigationBarItems(trailing: Button("Cancel",
                                                         action: {
                        backpackViewModel.onCancel()
                    }))
            }
        })
        .sheet(unwrapping: self.$model.destination,
               case: /ContentViewModel.Destination.catchScene) { $catchViewModel in
            NavigationStack {
                CatchView(model: catchViewModel)
            }
        }
    }
}
