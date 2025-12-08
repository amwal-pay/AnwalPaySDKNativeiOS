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
    @State private var shouldShowPaymentScreen = false
    @State private var lastViewModel: PaymentFormViewModel?
   



    var body: some Scene {
        WindowGroup {
            let _ = print("🔴 [App] Starting app with customerId: \(UserDefaults.standard.string(forKey: "customer_id") ?? "")")
            
            NavigationStack {
                FormView(onSubmit:  { viewModel in
                    print("🟠 [FormView] Submit button tapped with customerId: \(viewModel.customerId)")
                    lastViewModel = viewModel
                    shouldShowPaymentScreen = true
                    startSdk(viewModel: viewModel)
                })
                .navigationDestination(isPresented: $shouldShowPaymentScreen) {
                    
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
        print("🟣 [handleResponse] Raw response: \(response ?? "nil")")
        guard let response = response else {
            print("❌ [handleResponse] Response is nil")
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
                print("✅ Payment completed. Response: \(json)")
                
                // Update customer ID only if it exists and is not null in the response
                if let customerTokenId = json["customerId"] as? String, customerTokenId.lowercased() != "null" && !customerTokenId.isEmpty {
                    print("🔄 Updating customer ID: \(customerTokenId)")
                    // Update both UserDefaults and view model
                    UserDefaults.standard.set(customerTokenId, forKey: "customer_id")
                    self.lastViewModel?.customerId = customerTokenId
                } else {
                    print("ℹ️ Keeping existing customer ID as the response contained null or empty customerId")
                }
                
                // Dismiss the payment screen
                DispatchQueue.main.async {
                    self.shouldShowPaymentScreen = false
                    self.config = nil
                }
            } else {
                print("Failed to parse JSON into dictionary.")
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }


    
    func startSdk(viewModel: PaymentFormViewModel) {
        print("🟠 [startSdk] Starting SDK with viewModel - customerId: \(viewModel.customerId)")
        
        let fetchAndConfigureSDK: (PaymentFormViewModel) -> Void = { [self] vm in
            print("🟠 [fetchAndConfigureSDK] Fetching session token with customerId: \(vm.customerId)")
            
            networkClient.fetchSessionToken(
                env: vm.selectedEnv,
                merchantId: vm.merchantId,
                customerId: vm.customerId,
                secureHashValue: vm.secureHash
            ) { [self] sessionToken in
                print("🟠 [fetchSessionToken] Received session token: \(sessionToken?.prefix(10) ?? "nil")...")
                guard let token = sessionToken else {
                    print("Failed to fetch session token.")
                    return
                }
                
                print("Session token: \(token)")
                print("customer id: \(vm.customerId ?? "nullString")")
                
                let sdkTransactionType: Config.TransactionType
                switch vm.transactionType {
                case .NFC:
                    sdkTransactionType = .nfc
                case .CARD_WALLET:
                    sdkTransactionType = .cardWallet
                case .APPLE_PAY:
                    sdkTransactionType = .applePay
                }
                
                DispatchQueue.main.async { [self] in
                    config = Config(
                        environment: vm.selectedEnv,
                        sessionToken: token,
                        currency: vm.currency,
                        amount: vm.amount,
                        merchantId: vm.merchantId,
                        terminalId: vm.terminalId,
                        locale: vm.language,
                        transactionType: sdkTransactionType,
                        transactionId: Config.generateTransactionId(),
                        additionValues: [
                            "merchantIdentifier": "merchant.shahd.test"
                        ],
                        merchantReference: vm.merchantReference.isEmpty ? nil : vm.merchantReference
                    )
                }
            }
        }
        
        // Always ensure we have a customer ID (empty string if not set)
        let savedCustomerId = UserDefaults.standard.string(forKey: "customer_id") ?? ""
        if !savedCustomerId.isEmpty {
            // Use the saved customer ID if available
            var updatedViewModel = viewModel
            updatedViewModel.customerId = savedCustomerId
            lastViewModel = updatedViewModel
            fetchAndConfigureSDK(updatedViewModel)
        } else {
            lastViewModel = viewModel
            fetchAndConfigureSDK(viewModel)
        }
    }
}
