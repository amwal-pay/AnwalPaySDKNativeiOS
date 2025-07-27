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
                .navigationDestination(isPresented: Binding<Bool>(
                    get: { config != nil },
                    set: { if !$0 { config = nil } }
                )) {
                    
                                   if let config = config {
                                       SDKViewControllerRepresentable(
                                           config: config,
                                           onResponse: {
                                               response in handleResponse(response: response)
                    
                                           },
                                           onCustomerId:  { customerId in
                                               UserDefaults.standard.set(customerId, forKey: "customer_id")
                                           }
                                       ) .navigationBarHidden(true)
                                   }
                               }
            }
        }
    }
    
    func handleResponse(response: String?) {
        guard let response = response else {
            print("Response is nil.")
            return
        }

        // Convert the string to Data
        guard let data = response.data(using: .utf8) else {
            print("Failed to convert string to Data.")
            return
        }

        // Parse the JSON
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Extract customerTokenId
                if let customerTokenId = json["customerId"] as? String {
                    UserDefaults.standard.set( customerTokenId, forKey: "customer_id")
                } else {
                    print("Customer Token ID not found.")
                }
            } else {
                print("Failed to parse JSON into dictionary.")
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }


    
    func startSdk(viewModel: PaymentFormViewModel) {
        networkClient.fetchSessionToken(
            env: viewModel.selectedEnv,
            merchantId: viewModel.merchantId,
            customerId: viewModel.customerId,
            secureHashValue: viewModel.secureHash
        ) { [self] sessionToken in
            if let token = sessionToken {
                
                print("Session token: \(token)")
                print("customer id: \(viewModel.customerId ?? "nullString")")
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
                    locale: viewModel.language,
                    transactionType: sdkTransactionType,
                    transactionId: Config.generateTransactionId(),
                    additionValues: [
                      "merchantIdentifier": "merchant.shahd.test"
                  ] // Optional: Includes merchantIdentifier for Apple Pay
                )
                                
            } else {
                print("Failed to fetch session token.")
            }
        }
    }
}
