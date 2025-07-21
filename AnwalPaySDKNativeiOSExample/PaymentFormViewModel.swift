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
    
    @Published var merchantId: String = "73092"
    @Published var terminalId: String = "861788"
    @Published var amount: String = "1"
    @Published var currency: Config.Currency = .OMR
    @Published var language: Config.Locale = .en
    @Published var transactionType: TransactionType = .CARD_WALLET
    @Published var secureHash: String = "21C4060616C3E1F221EB1FF83184C70BA77E6AB2F204C3339A64FC902072CFCE"
    @Published var selectedEnv: Config.Environment = .SIT
    @Published var customerId: String?
}
