import SwiftUINavigation
import SwiftUI
import Common
import NetworkKit

@main
struct PokedexApp: App {
    let dataProvider = DataProvider()
//    let catchModel = CatchModel(searchService: PokemonSearchService(),
//                                        dataProvider: DataProvider(),
//                                        destination: nil,
//                                        blockCall: false)
    
    var body: some Scene {
        WindowGroup {
            HomeView(model: HomeModel(dataProvider: dataProvider))
                .task {
                    dataProvider.start()
                }
            // ContentView(contentViewModel: ContentViewModel(destination: .catchScene(catchViewModel)))
        }
    }
}
