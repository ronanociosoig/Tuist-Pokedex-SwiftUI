import SwiftUI
import SwiftUINavigation

struct HomeView: View {
    @ObservedObject var model: HomeModel
    
    init(model: HomeModel) {
        self.model = model
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
               case: /HomeModel.Destination.backpackScene,
               content: { $backpackModel in
            NavigationStack {
                BackpackView(model: backpackModel)
                    .navigationBarItems(trailing: Button("Cancel",
                                                         action: {
                        backpackModel.onCancel()
                    }))
            }
        })
        .sheet(unwrapping: self.$model.destination,
               case: /HomeModel.Destination.catchScene) { $catchModel in
            NavigationStack {
                CatchView(model: catchModel)
            }
        }
    }
}
