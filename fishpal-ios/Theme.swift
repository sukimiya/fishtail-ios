import SwiftUI

extension Color {
    // 参考原 PWA 配色
    static let fishBG     = Color(r: 0x0b, g: 0x15, b: 0x25) // #0b1525 主背景
    static let fishCard   = Color(r: 0x14, g: 0x1f, b: 0x33) // #141f33 卡片
    static let fishInput  = Color(r: 0x0d, g: 0x1f, b: 0x3c) // #0d1f3c 输入框/深色块
    static let fishTrack  = Color(r: 0x1f, g: 0x3a, b: 0x5c) // #1f3a5c 进度轨道
    static let fishBlue   = Color(r: 0x1a, g: 0x8c, b: 0xff) // #1a8cff 主蓝色
    static let fishText   = Color(r: 0xe0, g: 0xe8, b: 0xf0) // #e0e8f0 主文字
    static let fishMuted  = Color(r: 0x8a, g: 0xb4, b: 0xf8) // #8ab4f8 次要文字
    static let fishBorder = Color.white.opacity(0.08)

    private init(r: UInt8, g: UInt8, b: UInt8) {
        self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}
