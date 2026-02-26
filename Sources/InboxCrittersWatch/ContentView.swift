import SwiftUI

struct ContentView: View {
    @AppStorage("ic_mit") private var mit: Int = 0
    @AppStorage("ic_high") private var high: Int = 0
    @AppStorage("ic_normal") private var normal: Int = 0
    @AppStorage("ic_someday") private var someday: Int = 0

    var body: some View {
        VStack(spacing: 6) {
            Text("🧠 Inbox")
                .font(.headline)
            Grid(horizontalSpacing: 12, verticalSpacing: 6) {
                GridRow {
                    Label("\(mit)", systemImage: "circle.fill")
                        .foregroundStyle(.red)
                    Label("\(high)", systemImage: "circle.fill")
                        .foregroundStyle(.yellow)
                }
                GridRow {
                    Label("\(normal)", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                    Label("\(someday)", systemImage: "circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .font(.caption)
            Text("MIT · High · Normal · Someday")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview { ContentView() }
