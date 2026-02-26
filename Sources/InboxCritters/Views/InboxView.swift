import SwiftUI
import SpriteKit

struct InboxView: View {
    @EnvironmentObject private var store: CritterStore
    @State private var inputText = ""
    @State private var scene: BrainDumpScene?
    @FocusState private var focused: Bool
    @State private var shooCount = 0
    @State private var showStats = false

    var body: some View {
        ZStack(alignment: .top) {
            // SpriteKit scene
            Group {
                if let scene {
                    SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                        .ignoresSafeArea()
                }
            }

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .background(.black.opacity(0.5))

                // Input bar
                inputBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.4))

                Spacer()
            }

            // Stats overlay
            if showStats {
                statsOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onAppear { setupScene() }
        .animation(.easeInOut(duration: 0.25), value: showStats)
    }

    // MARK: - Sub-views

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("🧠 Brain Dump")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Sorted: \(store.totalSorted)  |  Stolen: \(store.stolenCount)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Button {
                withAnimation { showStats.toggle() }
            } label: {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .accessibilityLabel("Show sorted thoughts")
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("", text: $inputText, prompt:
                Text("What's on your mind?")
                    .foregroundStyle(.white.opacity(0.4))
            )
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .focused($focused)
            .submitLabel(.send)
            .onSubmit { send() }

            Button(action: send) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(inputText.isEmpty ? .white.opacity(0.3) : .cyan)
            }
            .disabled(inputText.isEmpty)
            .accessibilityLabel("Send thought")
            .accessibilityHint("Sends your thought as a floating orb into the brain dump")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.15), lineWidth: 1))
    }

    private var statsOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
                .onTapGesture { withAnimation { showStats = false } }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("Close stats")
            VStack(spacing: 0) {
                Spacer().frame(height: 100)
                VStack(spacing: 0) {
                    HStack {
                        Text("Sorted Thoughts")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        Button { withAnimation { showStats = false } } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .accessibilityLabel("Close")
                    }
                    .padding()

                    Divider().background(.white.opacity(0.15))

                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Bucket.allCases, id: \.self) { bucket in
                                bucketSection(bucket)
                            }
                        }
                    }
                }
                .background(Color(red: 0.1, green: 0.12, blue: 0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                Spacer()
            }
        }
    }

    private func bucketSection(_ bucket: Bucket) -> some View {
        let thoughts = store.thoughts(in: bucket)
        return VStack(alignment: .leading, spacing: 0) {
            if !thoughts.isEmpty {
                HStack {
                    Text(bucket.emoji + " " + bucket.label)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                    Spacer()
                    Text("\(thoughts.count)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                ForEach(thoughts) { t in
                    Text(t.text)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                    Divider().background(.white.opacity(0.07)).padding(.leading, 20)
                }
            }
        }
    }

    // MARK: - Actions

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        let orb = ThoughtOrb(text: text)
        inputText = ""
        scene?.spawnOrb(orb)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func setupScene() {
        let s = BrainDumpScene()
        s.scaleMode = .resizeFill
        s.onSorted  = { @MainActor orb, bucket in store.sort(orb: orb, into: bucket) }
        s.onStolen  = { @MainActor in store.recordStolen() }
        s.onCritterTapped = { @MainActor in shooCount += 1 }
        scene = s
    }
}
