import SwiftUI

extension Color {
    static let fishBG     = Color(r: 0x0b, g: 0x15, b: 0x25)
    static let fishCard   = Color(r: 0x14, g: 0x1f, b: 0x33)
    static let fishInput  = Color(r: 0x0d, g: 0x1f, b: 0x3c)
    static let fishTrack  = Color(r: 0x1f, g: 0x3a, b: 0x5c)
    static let fishBlue   = Color(r: 0x1a, g: 0x8c, b: 0xff)
    static let fishText   = Color(r: 0xe0, g: 0xe8, b: 0xf0)
    static let fishMuted  = Color(r: 0x8a, g: 0xb4, b: 0xf8)
    static let fishBorder = Color.white.opacity(0.08)
    static let fishGreen  = Color(r: 0x4c, g: 0xaf, b: 0x50)
    static let fishOrange = Color(r: 0xff, g: 0x98, b: 0x00)
    static let fishRed    = Color(r: 0xf4, g: 0x43, b: 0x36)

    static func scoreColor(for score: Double) -> Color {
        switch score {
        case 0.7...: return .fishGreen
        case 0.4...: return .fishOrange
        default:     return .fishRed
        }
    }

    private init(r: UInt8, g: UInt8, b: UInt8) {
        self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}
