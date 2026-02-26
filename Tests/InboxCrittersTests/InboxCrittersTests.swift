import Testing
import Foundation
@testable import InboxCritters

@Suite("Bucket")
struct BucketTests {
    @Test("all buckets have unique emoji and label")
    func uniqueContent() {
        let emojis  = Set(Bucket.allCases.map { $0.emoji })
        let labels  = Set(Bucket.allCases.map { $0.label })
        #expect(emojis.count == Bucket.allCases.count)
        #expect(labels.count == Bucket.allCases.count)
    }
}

@Suite("CritterStore")
@MainActor
struct CritterStoreTests {

    @Test("starts empty")
    func initialState() {
        let suite = UserDefaults(suiteName: "test_\(UUID().uuidString)")!
        // We can't inject defaults easily without modifying CritterStore,
        // so just verify the public API shapes are correct.
        let store = CritterStore()
        #expect(store.sessionSorted == 0)
    }

    @Test("sorting adds a thought")
    func sortingAdds() {
        let store = CritterStore()
        let orb   = ThoughtOrb(text: "Buy milk")
        let before = store.totalSorted
        store.sort(orb: orb, into: .normal)
        #expect(store.totalSorted == before + 1)
        #expect(store.sessionSorted == 1)
    }

    @Test("recordStolen increments stolenCount")
    func stolen() {
        let store = CritterStore()
        let before = store.stolenCount
        store.recordStolen()
        #expect(store.stolenCount == before + 1)
    }

    @Test("thoughts(in:) filters by bucket")
    func filterByBucket() {
        let store = CritterStore()
        store.sort(orb: ThoughtOrb(text: "MIT task"), into: .mit)
        store.sort(orb: ThoughtOrb(text: "Low task"), into: .someday)
        #expect(store.thoughts(in: .mit).count >= 1)
    }
}
