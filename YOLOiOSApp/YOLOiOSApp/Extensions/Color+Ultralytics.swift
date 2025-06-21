// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI

extension Color {
    // Primary colors
    static let ultralyticsLime = Color(red: 207/255, green: 255/255, blue: 26/255) // #CFFF1A
    static let ultralyticsBrown = Color(red: 106/255, green: 85/255, blue: 69/255) // #6A5545
    
    // Surface colors
    static let ultralyticsSurfaceDark = Color(red: 23/255, green: 23/255, blue: 23/255) // #171717
    static let ultralyticsSurface = Color(red: 33/255, green: 33/255, blue: 33/255) // #212121
    
    // Text colors
    static let ultralyticsTextPrimary = Color.white
    static let ultralyticsTextSubtle = Color.white.opacity(0.6)
    
    // Additional colors from design system
    static let ultralyticsBackground = Color(red: 13/255, green: 13/255, blue: 13/255) // #0D0D0D
    static let ultralyticsAccent = ultralyticsLime
}