//
//  Colors.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    /// \#FFB900 Color(red: 1, green: 185.0/255.0, blue: 0)
    static let zYellow = Color(red: 1, green: 185.0/255.0, blue: 0)
    
    static let arrrBlue = Color(red: 62.0/255.0, green: 180.0/255.0, blue: 206.0/255.0)
    
    /// Transparent things blue
    /// \#4A90E2 Color(red:24/255, red: 144/255, blue: 226/255)
    static let zTransparentBlue = Color(red: 24/255, green: 144/255, blue: 226/255)
    
    /// \#FFD000 Color(red: 1, red: 0.82, blue: 0)
    static let zAmberGradient0 = Color(red: 1.0, green: 0.82, blue: 0.0)
    /// Color(red: 1.0, green:0.64, blue:0.0)
    static let zAmberGradient1 = Color(red: 1.0, green:0.64, blue:0.0)
    
    /// \#FF9400
    static let zAmberGradient2 = Color(red: 1.0, green:0.74, blue:0.0)
    
    ///  \#FFB300 Color(red: 1.0, green:0.70, blue:0.0)
    static let zAmberGradient3 = Color(red: 1.0, green:0.70, blue:0.0)
    
    /// \#FF9300 Color(red: 1.0, green: 0.58, blue: 0.0)
    static let zAmberGradient4 = Color(red: 1.0, green: 0.58, blue: 0.0)
    
    static let zBlackGradient1 = Color(red:0.16, green:0.16, blue:0.17)
    
    static let zBlackGradient2 = Color.black
    
    static let zDarkGradient1 = Color.init(red: 0.13, green: 0.14, blue: 0.15)
    
    static let zDarkGradient2 = Color.init(red: 0.11, green: 0.12, blue: 0.14)
    
    /// \#282828 Color(red: 0.17, green: 0.17, blue: 0.17)
    static let zGray = Color(red:0.16, green:0.16, blue:0.16)
    
    static let zSlightLightGray = Color(red:31/255, green:32/255, blue:37/255)
    
    /// \#4A4A4A Color(red: 74/255, green: 74/255, blue: 74/255)
    static let zGray2 = Color(red: 74/255, green: 74/255, blue: 74/255)
    
    /// \#656565 Color(red: 0.4, green: 0.4, blue: 0.4)
    static let zGray3 = Color(red: 0.4, green: 0.4, blue: 0.4)
    
    /// Color(red: 151/255, green: 151/255, blue: 151/255)
    static let zLightGray = Color(red: 151/255, green: 151/255, blue: 151/255)
    
    /// \#D8D8D8 Color(red:0.85, green:0.85, blue:0.85)
    static let zLightGray2 = Color(red:0.85, green:0.85, blue:0.85)
    
    /// Color(red: 0.17, green: 0.17, blue: 0.17)
    static let zDarkGray1 = Color(red: 0.17, green: 0.17, blue: 0.17)
    
    /// \#171717 Color(red: 0.09, green: 0.09, blue: 0.09)
    static let zDarkGray2 = Color(red: 0.09, green: 0.09, blue: 0.09)
    
    /// \#A7A7A7 Color(red: 0.65, green: 0.65, blue: 0.65)
    static let zDarkGray3 = Color(red: 0.65, green: 0.65, blue: 0.65)
    
    /// \#F7F7F7
    static let zDudeItsAlmostWhite = Color(red: 247/255, green: 247/255, blue: 247/255)
   
    static let zTextLightGray = Color(red: 107/255, green: 110/255, blue: 118/255)
   
    
    
    /// # Card colors
    
    
    /// \#FF4CA6 red:1.00, green:0.30, blue:0.65
    static let zNegativeZecAmount = Color(red:1.0, green:0.30, blue:0.65)
    
    /// \#2AFF6E Color(red:0.16, green:1.00, blue:0.43)
    static let zPositiveZecAmount = Color(red:0.16, green:1.00, blue:0.43)
    
    
    /// # Paid Card gradient
    
    /// \#FFB322 Color(red:1.0, green:0.70, blue:0.13)
    static let zPendingCardGradient1 = Color(red:1.0, green:0.70, blue:0.13)
    
    /// \# FF4242 Color(red:1.0, green:0.26, blue:0.26)
    static let zPendingCardGradient2 = Color(red:1.0, green:0.26, blue:0.26)
    
    // \# FFD649 Color(red: 1, green: 214/255, blue: 73/255)
    static let zPaidCardGradient1 = Color(red: 1, green: 214/255, blue: 73/255)
    
    // \# FFA918 Color(red: 1, green: 169/255, blue: 24/255)
    static let zPaidCardGradient2 = Color(red: 1, green: 169/255, blue: 24/255)
    
    // \#D2D2D2 Color(red: 210/255, green: 210/255, blue: 210/255)
    static let zFailedCardGradient1 = Color(red: 210/255, green: 210/255, blue: 210/255)
    
    // \#838383 Color(red: 131/255, green: 131/255, blue: 131/255)
    static let zFailedCardGradient2 = Color(red: 131/255, green: 131/255, blue: 131/255)
    
    // \#7DFF81 Color(red:125/255, green: 1, blue: 129/255)
    static let zReceivedCardGradient1 = Color(red:125/255, green: 1, blue: 129/255)
    
    // \#42EEFF Color(red:66/255, green: 238/255, blue: 1)
    static let zReceivedCardGradient2 = Color(red:66/255, green: 238/255, blue: 1)
    
    /// #Hold Button
    /// \#979797  Color(red:0.59, green:0.59, blue:0.59)
    static let zHoldButtonGray = Color(red:0.59, green:0.59, blue:0.59)
    
    // Home tab view colors
    
    static let arrrBarTintColor = Color.init(red: 0.13, green: 0.14, blue: 0.15)
    
    static let arrrBarAccentColor = Color.init(red: 194.0/255.0, green: 136.0/255.0, blue: 101.0/255.0)
    
    
    /// Amount Breakdown Gray
    
    static let zLeastSignificantAmountGray = Color(red: 119/255, green: 119/255, blue: 119/255)
    
    static let zBalanceBreakdownGradient1 = Color(red: 42/255, green: 41/255, blue: 51/255)
    
    static let zBalanceBreakdownGradient2 = Color(red: 45/255, green: 45/255, blue: 51/255)
    
    static let zBalanceBreakdownItem0 = Color(red: 44/255, green: 44/255, blue: 52/255)
    static let zBalanceBreakdownItem1 = Color(red: 134/255, green: 134/255, blue: 134/255, opacity: 0.081)
    static let zBalanceBreakdownItem2 = Color(red: 0, green: 0, blue: 0, opacity: 0.081)
    
    
    /// Settings screen colors
    static let zSettingsSectionHeader = Color.init(red: 107.0/255.0, green: 110.0/255.0, blue: 118.0/255.0)
    static let zSettingsRowBackground = Color.init(red: 25.0/255.0, green: 28.0/255.0, blue: 29.0/255.0)
    static let onColor = Color.init(red: 12.0/255.0, green: 38.0/255.0, blue: 48.0/255.0)
    static let offColor = Color.init(red: 27.0/255.0, green: 30.0/255.0, blue: 32.0/255.0)
    static let thumbOnColor = Color.init(red: 120.0/255.0, green: 176.0/255.0, blue: 193.0/255.0)
    static let thumbOffColor = Color.init(red: 83.0/255.0, green: 94.0/255.0, blue: 97.0/255.0)
    static let darkShadow = Color.init(red: 0.06, green: 0.07, blue: 0.07)
    static let lightShadow = Color.init(red: 0.26, green: 0.27, blue: 0.3)
    static let depthRoundedRectColor = Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0)
    static let textTitleColor = Color.init(red: 0.59, green: 0.61, blue: 0.63)
    
    static let screenBgColor = Color.init(red: 33.0/255.0, green: 36.0/255.0, blue: 38.0/255.0)
    
    // Wallet Screen Color
    
    static let zARRRTextColor = Color.init(red: 218.0/255.0, green: 183.0/255.0, blue: 114.0/255.0)
    
    static let zARRRSentColor = Color.init(red: 218.0/255.0, green: 183.0/255.0, blue: 114.0/255.0)
    
    static let zARRRReceivedColor = Color.init(red: 26.0/255.0, green: 135.0/255.0, blue: 158.0/255.0)
    
    static let zARRRSubtitleColor = Color.init(red: 150.0/255.0, green: 150.0/255.0, blue: 160.0/255.0)
    
    static let zARRRTextColorLightYellow = Color.init(red: 132.0/255.0, green: 124.0/255.0, blue: 115.0/255.0)
    
    static let zARRRReplySelectedColor = Color.init(red: 106.0/255.0, green: 222.0/255.0, blue: 247.0/255.0)
}

extension Gradient {
    
    static let paidCard = Gradient(colors: [Color.zPaidCardGradient1, .zPaidCardGradient2])
    
    static let failedCard = Gradient(colors: [Color.zFailedCardGradient1, .zFailedCardGradient2])
    
    static let receivedCard = Gradient(colors: [Color.zReceivedCardGradient1, .zReceivedCardGradient2])
}


extension UIColor {
    static let zLightGray = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    static let zDarkGray = UIColor(red: 0.02, green: 0.02, blue: 0.02, alpha: 1)
}
