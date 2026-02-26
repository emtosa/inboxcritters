import SpriteKit
import UIKit
import AudioToolbox

// MARK: - BrainDumpScene

final class BrainDumpScene: SKScene {

    // Callbacks
    var onSorted:        (@MainActor (ThoughtOrb, Bucket) -> Void)?
    var onStolen:        (@MainActor () -> Void)?
    var onCritterTapped: (@MainActor () -> Void)?

    // MARK: - State
    private var draggedOrb:    OrbNode?
    private var dragOffset:    CGPoint = .zero
    private var bucketZones:   [(bucket: Bucket, rect: CGRect)] = []
    private var critterSpawnTimer: TimeInterval = 0

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.06, blue: 0.18, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        setupBuckets()
        scheduleInitialCritter()
    }

    // MARK: - Buckets

    private func setupBuckets() {
        let buckets = Bucket.allCases
        let w = frame.width / CGFloat(buckets.count)
        let h: CGFloat = 72

        for (i, bucket) in buckets.enumerated() {
            let x = CGFloat(i) * w
            let rect = CGRect(x: x, y: frame.minY, width: w, height: h)
            bucketZones.append((bucket, rect))

            // Visual bucket
            let zone = SKShapeNode(rect: CGRect(x: 0, y: 0, width: w - 2, height: h), cornerRadius: 10)
            let c = bucket.color
            zone.fillColor   = SKColor(red: c.r, green: c.g, blue: c.b, alpha: 0.18)
            zone.strokeColor = SKColor(red: c.r, green: c.g, blue: c.b, alpha: 0.6)
            zone.lineWidth   = 2
            zone.position    = CGPoint(x: x + 1, y: frame.minY)
            zone.zPosition   = 0
            addChild(zone)

            let icon = SKLabelNode(text: bucket.emoji)
            icon.fontSize = 26
            icon.position = CGPoint(x: x + w / 2, y: frame.minY + 24)
            icon.zPosition = 1
            addChild(icon)

            let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            lbl.fontSize  = 11
            lbl.fontColor = SKColor(red: c.r, green: c.g, blue: c.b, alpha: 1)
            lbl.text      = bucket.label
            lbl.position  = CGPoint(x: x + w / 2, y: frame.minY + 52)
            lbl.zPosition = 1
            addChild(lbl)
        }
    }

    // MARK: - Spawn orb

    func spawnOrb(_ orb: ThoughtOrb) {
        let node = OrbNode(orb: orb)
        let x = CGFloat.random(in: OrbNode.radius...(frame.maxX - OrbNode.radius))
        node.position = CGPoint(x: x, y: frame.maxY - 160)
        node.zPosition = 2
        addChild(node)
        node.animateIn()
    }

    // MARK: - Critters

    private func scheduleInitialCritter() {
        run(SKAction.sequence([
            SKAction.wait(forDuration: 4),
            SKAction.run { [weak self] in self?.spawnCritter() }
        ]))
    }

    private func spawnCritter() {
        let kind = CritterKind.allCases.randomElement()!
        let critter = CritterNode(kind: kind)
        let x = Bool.random() ? frame.minX + 20 : frame.maxX - 20
        let y = CGFloat.random(in: frame.midY...(frame.maxY - 150))
        critter.position = CGPoint(x: x, y: y)
        critter.zPosition = 3
        addChild(critter)
        critter.startPatrol(in: frame)

        // Re-schedule next critter
        run(SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 6...12)),
            SKAction.run { [weak self] in self?.spawnCritter() }
        ]))

        // Auto-remove critter if not tapped
        critter.run(SKAction.sequence([
            SKAction.wait(forDuration: 8),
            SKAction.run { [weak self] in
                if critter.parent != nil {
                    if let victim = self?.children.compactMap({ $0 as? OrbNode }).randomElement() {
                        victim.pop(correct: false)
                        Task { @MainActor [weak self] in self?.onStolen?() }
                    }
                }
            },
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Touch / Drag

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        // Shoo critter?
        if let critter = nodes(at: loc).compactMap({ $0 as? CritterNode }).first
            ?? nodes(at: loc).compactMap({ $0.parent as? CritterNode }).first {
            critter.shoo()
            Task { @MainActor [weak self] in self?.onCritterTapped?() }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }

        // Start dragging orb
        if let orb = nodes(at: loc).compactMap({ $0 as? OrbNode }).first
            ?? nodes(at: loc).compactMap({ $0.parent as? OrbNode }).first {
            orb.physicsBody?.isDynamic = false
            draggedOrb = orb
            dragOffset = CGPoint(x: orb.position.x - loc.x, y: orb.position.y - loc.y)
            orb.run(SKAction.scale(to: 1.15, duration: 0.1))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let orb = draggedOrb else { return }
        let loc = touch.location(in: self)
        orb.position = CGPoint(x: loc.x + dragOffset.x, y: loc.y + dragOffset.y)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let orb = draggedOrb else { return }
        let loc = touch.location(in: self)
        draggedOrb = nil
        orb.run(SKAction.scale(to: 1.0, duration: 0.08))

        // Check if dropped into a bucket
        if let match = bucketZones.first(where: { $0.rect.contains(loc) }) {
            let thoughtOrb = orb.orb
            let bucket     = match.bucket
            orb.pop(correct: true)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            AudioServicesPlaySystemSound(1057)
            Task { @MainActor [weak self] in self?.onSorted?(thoughtOrb, bucket) }
        } else {
            // Release back to physics
            orb.physicsBody?.isDynamic = true
            orb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -5))
        }
    }
}
