import XCTest
import SwiftUI
@testable import InboxCritters

@MainActor
final class ScreenshotTests: XCTestCase {

    let outputDir: URL = {
        if let dir = ProcessInfo.processInfo.environment["SCREENSHOTS_DIR"] {
            return URL(fileURLWithPath: dir)
        }
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("AppStore/screenshots/en-US")
    }()

    let sizes: [(CGFloat, CGFloat)] = [(1320, 2868), (1284, 2778), (2064, 2752)]

    func testGenerateScreenshots() throws {
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        for (w, h) in sizes {
            let label = "\(Int(w))x\(Int(h))"
            save(MenuShot(w: w, h: h), w: w, h: h,    name: "01-menu-\(label)")
            save(GameShot(w: w, h: h), w: w, h: h,    name: "02-game-\(label)")
            save(SortedShot(w: w, h: h), w: w, h: h,  name: "03-sorted-\(label)")
            save(BucketsShot(w: w, h: h), w: w, h: h, name: "04-buckets-\(label)")
        }
    }

    private func save(_ view: some View, w: CGFloat = 0, h: CGFloat = 0, name: String) {
        let renderer = ImageRenderer(content: view)
        if w > 0 && h > 0 { renderer.proposedSize = .init(width: w, height: h) }
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage,
              let data = uiImage.jpegData(compressionQuality: 0.92) else { XCTFail("Render failed: \(name)"); return }
        let url = outputDir.appendingPathComponent("\(name).jpg")
        try? data.write(to: url)
        print("📸 \(url.lastPathComponent)")
    }
}

private struct MenuShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.06,blue:0.16), Color(red:0.1,green:0.16,blue:0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h * 0.04) {
                Spacer()
                Text("🐭🦟🐛").font(.system(size: h * 0.08))
                Text("Inbox Critters").font(.system(size: h * 0.046, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Text("Sort your thoughts before the critters steal them!").font(.system(size: h * 0.022, design: .rounded)).foregroundStyle(.white.opacity(0.6)).multilineTextAlignment(.center).padding(.horizontal, w * 0.12)
                Spacer()
                Text("BRAIN DUMP").font(.system(size: h * 0.025, weight: .heavy, design: .rounded))
                    .frame(width: w * 0.6, height: h * 0.07)
                    .background(Color.indigo).foregroundStyle(.white).clipShape(Capsule())
                Spacer()
            }
        }
    }
}

private struct GameShot: View {
    let w, h: CGFloat
    let orbs = ["Fix bug report 🔴", "Call dentist 🟡", "Read article 🔵"]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.06,blue:0.16), Color(red:0.1,green:0.16,blue:0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack {
                HStack { Spacer(); Text("Score: 7").font(.system(size: h*0.025, weight:.semibold, design:.rounded)).foregroundStyle(.white).padding() }
                // Critter floating
                HStack { Spacer(); Text("🐭").font(.system(size: h*0.06)).offset(x: -w*0.05); Spacer() }
                Spacer()
                // Orbs
                ForEach(orbs, id:\.self) { orb in
                    Text(orb).font(.system(size: h*0.022, design:.rounded)).foregroundStyle(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                }
                Spacer()
                // Buckets
                HStack(spacing: w*0.03) {
                    ForEach([("🔴","MIT"),("🟡","High"),("🟢","Normal"),("🔵","Someday")], id:\.0) { (c,l) in
                        VStack(spacing: 4) {
                            Text(c).font(.system(size: h*0.05))
                            Text(l).font(.system(size: h*0.015, weight:.semibold, design:.rounded)).foregroundStyle(.white.opacity(0.7))
                        }
                        .frame(width: w*0.2, height: h*0.12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                    }
                }.padding(.bottom, h*0.04)
            }
        }
    }
}

private struct SortedShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.06,blue:0.16), Color(red:0.1,green:0.16,blue:0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h*0.03) {
                Spacer()
                Text("🧠 Brain Dumped!").font(.system(size: h*0.042, weight:.heavy, design:.rounded)).foregroundStyle(.white)
                Text("12 thoughts sorted • 1 stolen by 🐭").font(.system(size: h*0.022, design:.rounded)).foregroundStyle(.white.opacity(0.6))
                HStack(spacing: w*0.06) {
                    VStack { Text("5").font(.system(size:h*0.05,weight:.heavy,design:.rounded)).foregroundStyle(.red); Text("MIT").font(.system(size:h*0.016,design:.rounded)).foregroundStyle(.white.opacity(0.5)) }
                    VStack { Text("3").font(.system(size:h*0.05,weight:.heavy,design:.rounded)).foregroundStyle(.yellow); Text("High").font(.system(size:h*0.016,design:.rounded)).foregroundStyle(.white.opacity(0.5)) }
                    VStack { Text("2").font(.system(size:h*0.05,weight:.heavy,design:.rounded)).foregroundStyle(.green); Text("Normal").font(.system(size:h*0.016,design:.rounded)).foregroundStyle(.white.opacity(0.5)) }
                    VStack { Text("2").font(.system(size:h*0.05,weight:.heavy,design:.rounded)).foregroundStyle(.blue); Text("Someday").font(.system(size:h*0.016,design:.rounded)).foregroundStyle(.white.opacity(0.5)) }
                }
                Spacer()
            }
        }
    }
}

private struct BucketsShot: View {
    let w, h: CGFloat
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.04,green:0.06,blue:0.16), Color(red:0.1,green:0.16,blue:0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: h*0.03) {
                Spacer()
                Text("4 Buckets, Infinite Clarity").font(.system(size: h*0.038, weight:.heavy, design:.rounded)).foregroundStyle(.white).multilineTextAlignment(.center)
                ForEach([("🔴 MIT","Most Important Task — do it now"),("🟡 High","Tackle this today"),("🟢 Normal","Schedule for the week"),("🔵 Someday","Great idea, future you's problem")], id:\.0) { (t,d) in
                    VStack(alignment:.leading, spacing:4) {
                        Text(t).font(.system(size:h*0.025,weight:.semibold,design:.rounded)).foregroundStyle(.white)
                        Text(d).font(.system(size:h*0.018,design:.rounded)).foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.horizontal, w*0.1)
                }
                Spacer()
            }
        }
    }
}
