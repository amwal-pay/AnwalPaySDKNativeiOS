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
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FormView(onSubmit:  { viewModel in
                    startSdk(viewModel: viewModel)
                })
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { config != nil },
                    set: { if !$0 { config = nil } }
                )) {
                    if let config = config {
                        ZStack {
                            // Transparent background helper
                            Color.clear
                            
                            SDKViewControllerRepresentable(
                                config: config,
                                onResponse: { _ in },
                                onCustomerId: { customerId in
                                    StorageClient.saveCustomerId(customerId)
                                }
                            )
                            .ignoresSafeArea()
                        }
                        .background(Color.clear)
                        // Attempt to make the hosting controller transparent
                        .presentationBackground(.clear)
                    }
                }
            }
        }
    }
    
    func startSdk(viewModel: PaymentFormViewModel) {
        let storedCustomerId = StorageClient.getCustomerId()
        networkClient.fetchSessionToken(
            env: .UAT,
            merchantId: viewModel.merchantId,
            customerId: storedCustomerId,
            secureHashValue: viewModel.secureHash
        ) { [self] sessionToken in
            if let token = sessionToken {
                
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
                    transactionId: Config.generateTransactionId(), // Optional: Can be nil for auto-generation
                    additionValues: [
                        "merchantIdentifier": "merchant.shahd.test",
                        "primaryColor": viewModel.primaryColorHex,
                        "secondaryColor": viewModel.secondaryColorHex,
                        "ignoreReceipt": String(viewModel.ignoreReceipt),
                        "useBottomSheetDesign": String(viewModel.useBottomSheetDesign)
                    ],
                    merchantReference: viewModel.merchantReference.isEmpty ? nil : viewModel.merchantReference
                )
                                
            } else {
                print("Failed to fetch session token.")
            }
        }
    }
}
