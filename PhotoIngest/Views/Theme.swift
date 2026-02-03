import SwiftUI

enum Theme {
    // MARK: - Brand Colors (Northwoods Community Church)
    // Primary brand blue: #02528A
    static let brandBlue = Color(red: 0.008, green: 0.322, blue: 0.541)

    // Brightened for dark mode UI interactive elements
    static let accent = Color(red: 0.05, green: 0.43, blue: 0.73)           // #0D6EBA
    static let accentHover = Color(red: 0.04, green: 0.38, blue: 0.65)      // #0A61A6
    static let accentMuted = accent.opacity(0.15)

    // Lighter blue for secondary highlights on dark backgrounds
    static let secondary = Color(red: 0.30, green: 0.60, blue: 0.85)        // #4D99D9
    static let secondaryMuted = secondary.opacity(0.15)

    // MARK: - Surface Colors
    static let surface = Color(white: 0.17)        // #2C2C2E card/panel
    static let surfaceHover = Color(white: 0.23)   // #3A3A3C
    static let border = Color(white: 0.28)         // #48484A

    // MARK: - Semantic
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)  // #34C759
    static let warning = Color(red: 1.0, green: 0.62, blue: 0.04)   // #FF9F0A
    static let error = Color(red: 1.0, green: 0.27, blue: 0.23)     // #FF453A

    // MARK: - Corner Radii
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16

    // MARK: - Spacing (8pt grid)
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
}
