import SwiftUINavigation
import SwiftUI
import Common
import NetworkKit

@main
struct PokedexApp: App {
    let appData: AppData = AppData(storage: Storage())
    
//    let catchViewModel = CatchViewModel(searchService: PokemonSearchService(),
//                                        dataProvider: DataProvider(),
//                                        destination: .showErrorAlert(.confirmError),
//                                        blockCall: true)
    
    var body: some Scene {
        WindowGroup {
            ContentView(contentViewModel: ContentViewModel())
        }
    }
}
