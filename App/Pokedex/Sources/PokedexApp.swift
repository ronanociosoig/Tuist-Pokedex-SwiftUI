import SwiftUINavigation
import SwiftUI
import Common
import NetworkKit

@main
struct PokedexApp: App {
    //let appData: AppData = AppData(storage: Storage())
    let dataProvider = DataProvider()
    
    let catchViewModel = CatchViewModel(searchService: PokemonSearchService(),
                                        dataProvider: DataProvider(),
                                        destination: nil,
                                        blockCall: false)
    
    var body: some Scene {
        WindowGroup {
            ContentView(contentViewModel: ContentViewModel(dataProvider: dataProvider))
                .task {
                    dataProvider.start()
                }
            // ContentView(contentViewModel: ContentViewModel(destination: .catchScene(catchViewModel)))
        }
    }
}
