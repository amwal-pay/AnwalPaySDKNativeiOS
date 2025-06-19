//
//  FormScreen.swift
//  AnwalPaySDKNativeiOSExample
//
//  Created by Ahmed Ganna on 09.02.25.
//


import SwiftUI
import amwalsdk
struct FormView: View {
    
    var onSubmit: (PaymentFormViewModel) -> Void  // Closure to handle config


    @StateObject private var viewModel = PaymentFormViewModel()
    @State private var showToast = false
    var body: some View {
        ZStack {
            VStack {
                Text("Amwal Pay Demo")
                    .font(.title)
                    .padding()
                    .toolbar{
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action: {
                            
                                UserDefaults.standard.removeObject(forKey: "customer_id")
                                showToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                   showToast = false
                                }
                            
                            }){
                    
                                Image(systemName: "trash") // "trash" or "trash.fill"
                                    .foregroundColor(.red) // Optional: set bin icon color
                            }}
                    }
              
                // Form Content
                ScrollView {
                    VStack(spacing: 16) {
                        // TextFields for input
                        CustomTextField(label: "Merchant Id", text: $viewModel.merchantId)
                        CustomTextField(label: "Terminal Id", text: $viewModel.terminalId)
                        CustomTextField(label: "Amount", text: $viewModel.amount)
                        CustomTextField(label: "Secret Key", text: $viewModel.secureHash)
                        
                        // Dropdowns for Currency, Language, Transaction Type, and Environment
                        CustomDropdown(
                            title: "Currency",
                            options: Config.Currency.allCases.map { $0.rawValue },
                            selectedValue: viewModel.currency.rawValue,
                            onValueChange: { newValue in
                                viewModel.currency = Config.Currency(rawValue: newValue) ?? .OMR
                            }
                        )
                        
                        CustomDropdown(
                            title: "Language",
                            options: Config.Locale.allCases.map { $0.rawValue },
                            selectedValue: viewModel.language.rawValue,
                            onValueChange: { newValue in
                                viewModel.language = Config.Locale(rawValue: newValue) ?? .en
                            }
                        )
                        
                        CustomDropdown(
                            title: "Transaction Type",
                            options: TransactionType.allCases.map { $0.rawValue },
                            selectedValue: viewModel.transactionType.rawValue,
                            onValueChange: { newValue in
                                viewModel.transactionType = TransactionType(rawValue: newValue) ?? .NFC
                            }
                        )
                        
                        CustomDropdown(
                            title: "Environment",
                            options: Config.Environment.allCases.map { $0.rawValue },
                            selectedValue: viewModel.selectedEnv.rawValue,
                            onValueChange: { newValue in
                                viewModel.selectedEnv = Config.Environment(rawValue: newValue) ?? .UAT
                            }
                        )

                        Spacer(minLength: 16)

                        // Initiate Payment Button
                        Button(action: {
                            let customerId = UserDefaults.standard.string(forKey: "customer_id")
                            viewModel.customerId = customerId
                            onSubmit(viewModel)
                            
                        }) {
                            Text("Initiate Payment Demo")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .navigationTitle("Payment Form")
                  
                }.padding(.horizontal).animation(.easeInOut, value: showToast)
              
            }
            
            if showToast {
                            Text("Customer Id Deleted")
                                .font(.body)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding()
                                .transition(.opacity)
                                .zIndex(1) // Ensure it appears above other elements
                        }
        }
            
        }

}

// Custom TextField Component
struct CustomTextField: View {
    var label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)

            TextField("Enter \(label)", text: $text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
                .padding(.bottom, 8)
        }
    }
}

// Custom Dropdown Component
struct CustomDropdown: View {
    var title: String
    var options: [String]
    var selectedValue: String
    var onValueChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                              .frame(maxWidth: .infinity, alignment: .leading)


            Picker(title, selection: Binding(
                get: { selectedValue },
                set: { newValue in
                    onValueChange(newValue)
                }
            )) {
                ForEach(options, id: \.self) { option in
                    Text(option)   .frame(maxWidth: .infinity, alignment: .leading)
                        .tag(option)
                }
            } .frame(maxWidth: .infinity, alignment: .leading)
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
            .padding(.bottom, 8)
        } .frame(maxWidth: .infinity, alignment: .leading)
       
    }
}
