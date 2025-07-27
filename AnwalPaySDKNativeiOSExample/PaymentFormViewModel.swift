//
//  conforming.swift
//  AnwalPaySDKNativeiOSExample
//
//  Created by Ahmed Ganna on 09.02.25.
//

import Foundation
import amwalsdk

// ViewModel class conforming to ObservableObject
class PaymentFormViewModel: ObservableObject {    
    
    @Published var merchantId: String = "7394"
    @Published var terminalId: String = "196456"
    @Published var amount: String = "1"
    @Published var currency: Config.Currency = .OMR
    @Published var language: Config.Locale = .en
    @Published var transactionType: TransactionType = .CARD_WALLET
    @Published var secureHash: String = "C0873776E2290E208FBBA27795DFC51B1531E73D187518106FE45DF344865149"
    @Published var selectedEnv: Config.Environment = .SIT
    @Published var customerId: String?
}
