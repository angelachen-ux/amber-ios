//
//  Color+Amber.swift
//  Amber
//
//  Created on 2026-01-17.
//

import SwiftUI

extension Color {
    // MARK: - Backgrounds
    static let amberBackground = Color(hex: "0A0A0A")
    static let amberCard = Color(hex: "1C1C1E")
    static let amberCardBackground = Color(hex: "1C1C1E")
    static let amberCardElevated = Color(hex: "2C2C2E")

    // MARK: - Text
    static let amberText = Color.white
    static let amberSecondaryText = Color(hex: "8E8E93")

    // MARK: - Accents
    static let amberBlue = Color(hex: "4A90D9")
    static let amberGold = Color(hex: "D4AF37")

    // MARK: - Health Dimensions
    static let healthSpiritual = Color(hex: "9B59B6")
    static let healthEmotional = Color(hex: "E74C3C")
    static let healthPhysical = Color(hex: "27AE60")
    static let healthIntellectual = Color(hex: "F39C12")
    static let healthSocial = Color(hex: "3498DB")
    static let healthFinancial = Color(hex: "1ABC9C")

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
