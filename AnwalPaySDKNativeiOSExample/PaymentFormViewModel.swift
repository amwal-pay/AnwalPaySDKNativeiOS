//
//  conforming.swift
//  AnwalPaySDKNativeiOSExample
//
//  Created by Ahmed Ganna on 09.02.25.
//

import Foundation
import SwiftUI
import amwalsdk

// ViewModel class conforming to ObservableObject
class PaymentFormViewModel: ObservableObject {    
    
    @Published var merchantId: String = "116194"
    @Published var terminalId: String = "708393"
    @Published var amount: String = "1"
    @Published var currency: Config.Currency = .OMR
    @Published var language: Config.Locale = .en
    @Published var transactionType: TransactionType = .CARD_WALLET
    @Published var secureHash: String = "2B03FCDC101D3F160744342BFBA0BEA0E835EE436B6A985BA30464418392C703"
    @Published var selectedEnv: Config.Environment = .UAT
    @Published var merchantReference: String = "1234"
    
    // Additional values
    @Published var primaryColor: Color = Color(hex: "#7F22FF") ?? .purple
    @Published var secondaryColor: Color = Color(hex: "#37658c") ?? .blue
    @Published var ignoreReceipt: Bool = false
    @Published var useBottomSheetDesign: Bool = false
    
    // Convert Color to hex string
    var primaryColorHex: String {
        return primaryColor.toHex() ?? "#7F22FF"
    }
    
    var secondaryColorHex: String {
        return secondaryColor.toHex() ?? "#37658c"
    }
}

// Color extension for hex conversion
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = components[0]
        let g = components.count > 1 ? components[1] : r
        let b = components.count > 2 ? components[2] : r
        
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
