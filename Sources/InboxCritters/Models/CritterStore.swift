import Foundation

@MainActor
final class CritterStore: ObservableObject {

    // MARK: - Published
    @Published private(set) var sorted:     [SortedThought] = []
    @Published private(set) var stolenCount: Int            = 0
    @Published private(set) var sessionSorted: Int          = 0

    private let defaults = UserDefaults.standard

    init() { load() }

    // MARK: - Sorting a thought

    func sort(orb: ThoughtOrb, into bucket: Bucket) {
        let thought = SortedThought(text: orb.text, bucket: bucket)
        sorted.append(thought)
        sessionSorted += 1
        persist()
    }

    func recordStolen() {
        stolenCount += 1
        persist()
    }

    // MARK: - Computed

    func thoughts(in bucket: Bucket) -> [SortedThought] {
        sorted.filter { $0.bucket == bucket }.sorted { $0.date > $1.date }
    }

    var totalSorted: Int { sorted.count }

    // MARK: - Persistence

    private func persist() {
        if let data = try? JSONEncoder().encode(sorted) {
            defaults.set(data, forKey: "critter_sorted")
        }
        defaults.set(stolenCount, forKey: "critter_stolen")
    }

    private func load() {
        if let data = defaults.data(forKey: "critter_sorted"),
           let s = try? JSONDecoder().decode([SortedThought].self, from: data) {
            sorted = s
        }
        stolenCount = defaults.integer(forKey: "critter_stolen")
    }
}
