//
//  AnwalPaySDKNativeiOSExampleApp.swift
//  AnwalPaySDKNativeiOSExample
//
//  Created by Ahmed Ganna on 06.02.25.
//

import SwiftUI
import amwalsdk

@main
struct AnwalPaySDKNativeiOSExampleApp: App {

    private let networkClient = NetworkClient()
    @State private var config: Config?
    @State private var showSDK = false
    
    var body: some Scene {
        WindowGroup {
            AmwalPayView(
                isPresented: $showSDK,
                config: config,
                onDismiss: {
                    showSDK = false
                    self.config = nil
                    LogsManager.shared.addLog("SDK dismissed", type: .info)
                },
                onCustomerId: { customerId in
                    StorageClient.saveCustomerId(customerId)
                    LogsManager.shared.addLog("Customer ID received: \(customerId)", type: .customerId)
                }
            ) {
                NavigationView {
                    FormView(onSubmit: { viewModel in
                        startSdk(viewModel: viewModel)
                    })
                }
                .navigationViewStyle(.stack)
            }
        }
    }
    
    func startSdk(viewModel: PaymentFormViewModel) {
        LogsManager.shared.addLog("Starting SDK initialization", type: .info)
        
        let storedCustomerId = StorageClient.getCustomerId()
        
        LogsManager.shared.addLog("Getting session token for merchant: \(viewModel.merchantId)", type: .info)
        
        networkClient.fetchSessionToken(
            env: viewModel.selectedEnv,
            merchantId: viewModel.merchantId,
            customerId: storedCustomerId,
            secureHashValue: viewModel.secureHash
        ) { [self] sessionToken in
            if let token = sessionToken {
                LogsManager.shared.addLog("Session token received, initializing SDK", type: .info)
                
                // Map the UI transaction type to the SDK transaction type
                let sdkTransactionType: Config.TransactionType
                switch viewModel.transactionType {
                case .NFC:
                    sdkTransactionType = .nfc
                case .CARD_WALLET:
                    sdkTransactionType = .cardWallet
                case .APPLE_PAY:
                    sdkTransactionType = .applePay
                }
                
                config = Config(
                    environment: viewModel.selectedEnv,
                    sessionToken: token,
                    currency: viewModel.currency,
                    amount: viewModel.amount,
                    merchantId: viewModel.merchantId,
                    terminalId: viewModel.terminalId,
                    customerId: storedCustomerId,
                    locale: viewModel.language,
                    transactionType: sdkTransactionType,
                    transactionId: Config.generateTransactionId(),
                    additionValues: [
                        "merchantIdentifier": "merchant.shahd.test",
                        "primaryColor": viewModel.primaryColorHex,
                        "secondaryColor": viewModel.secondaryColorHex,
                        "ignoreReceipt": String(viewModel.ignoreReceipt),
                        "useBottomSheetDesign": String(viewModel.useBottomSheetDesign)
                    ],
                    merchantReference: viewModel.merchantReference.isEmpty ? nil : viewModel.merchantReference
                )
                showSDK = true
                                
            } else {
                print("Failed to fetch session token.")
                LogsManager.shared.addLog("Failed to fetch session token", type: .error)
            }
        }
    }
}


