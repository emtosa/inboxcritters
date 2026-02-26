import SwiftUI

struct ContentView: View {
    @StateObject private var store = CritterStore()

    var body: some View {
        InboxView()
            .environmentObject(store)
    }
}
