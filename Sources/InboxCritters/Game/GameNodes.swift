import SpriteKit
import UIKit
import AudioToolbox

// MARK: - OrbNode

final class OrbNode: SKNode {
    let orb: ThoughtOrb

    private let bubble:    SKShapeNode
    private let textLabel: SKLabelNode
    static let radius: CGFloat = 44

    init(orb: ThoughtOrb) {
        self.orb = orb

        let r = OrbNode.radius
        bubble = SKShapeNode(circleOfRadius: r)
        bubble.fillColor   = SKColor.systemCyan.withAlphaComponent(0.22)
        bubble.strokeColor = SKColor.systemCyan
        bubble.lineWidth   = 2

        textLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        textLabel.fontSize              = 11
        textLabel.fontColor             = .white
        textLabel.horizontalAlignmentMode = .center
        textLabel.verticalAlignmentMode   = .center
        textLabel.preferredMaxLayoutWidth = r * 1.6
        textLabel.numberOfLines          = 2

        // Truncate long text for the orb display
        let display = orb.text.count > 22 ? String(orb.text.prefix(20)) + "…" : orb.text
        textLabel.text = display

        super.init()
        addChild(bubble)
        addChild(textLabel)

        physicsBody = SKPhysicsBody(circleOfRadius: r)
        physicsBody?.isDynamic        = true
        physicsBody?.affectedByGravity = true
        physicsBody?.restitution      = 0.3
        physicsBody?.friction         = 0.8
        physicsBody?.categoryBitMask  = 0x1
    }

    required init?(coder: NSCoder) { fatalError() }

    func animateIn() {
        alpha = 0; setScale(0.3)
        run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.25)
        ]))
    }

    func pop(correct: Bool) {
        removeAllActions()
        let color: SKColor = correct ? .systemGreen : .systemRed
        bubble.fillColor   = color.withAlphaComponent(0.45)
        bubble.strokeColor = color
        run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.18)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - CritterNode

final class CritterNode: SKNode {
    let kind: CritterKind

    init(kind: CritterKind) {
        self.kind = kind
        super.init()

        let label = SKLabelNode(text: kind.emoji)
        label.fontSize = 28
        label.verticalAlignmentMode = .center
        addChild(label)

        physicsBody = SKPhysicsBody(circleOfRadius: 14)
        physicsBody?.isDynamic        = false
        physicsBody?.affectedByGravity = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func startPatrol(in rect: CGRect) {
        let destX = Bool.random()
            ? CGFloat.random(in: rect.minX + 20...rect.midX)
            : CGFloat.random(in: rect.midX...rect.maxX - 20)
        let destY = CGFloat.random(in: rect.minY + 80...rect.maxY - 160)

        let move = SKAction.move(to: CGPoint(x: destX, y: destY), duration: Double.random(in: 1.5...3))
        run(SKAction.repeatForever(SKAction.sequence([
            move,
            SKAction.wait(forDuration: 0.4)
        ])))
    }

    func shoo() {
        removeAllActions()
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let dist: CGFloat = 200
        run(SKAction.sequence([
            SKAction.group([
                SKAction.move(by: CGVector(dx: cos(angle) * dist, dy: sin(angle) * dist), duration: 0.4),
                SKAction.fadeOut(withDuration: 0.35)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}
