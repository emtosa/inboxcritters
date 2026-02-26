# Inbox Critters

An ADHD brain-dump game by [Foculoom](https://foculoom.com).

## Concept

Type what's in your head. Thoughts appear as glowing orbs falling onto the screen. Drag each orb into the right bucket before critters steal them.

## Buckets (from Cairn's MIT Priority System)

| Emoji | Bucket | Use For |
|-------|--------|---------|
| 🔴 | MIT | Most Important Task — do today |
| 🟡 | High | Important but not urgent |
| 🟢 | Normal | Regular tasks |
| 🔵 | Someday | Maybe later |

## Critters

Three critters patrol the screen and try to steal unattended orbs:

- 🐭 Mouse — fast, sneaky
- 🦟 Mosquito — annoying, hard to catch
- 🐛 Worm — slow but persistent

**Tap a critter to shoo it away!** If it survives long enough, it will steal an orb.

## Gameplay

1. Type a thought and tap send → orb drops from top
2. Drag orb to the matching bucket at the bottom
3. Shoo critters before they steal your thoughts
4. View your sorted list any time via the list icon

## Tech

- Swift 6, SwiftUI + SpriteKit (drag physics)
- iOS 17+ / iPadOS 17+
- Thoughts saved locally, 100% offline

## Build

```bash
cd inboxcritters
xcodegen generate
open InboxCritters.xcodeproj
```
