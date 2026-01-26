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
    @State private var showLogsViewer = false

    var body: some View {
            VStack {
//                if let config = viewModel.config {
//                    onConfigReady(config)
//                }
                // Top Bar
                HStack {
                    Text("Amwal Pay Demo")
                        .font(.title)
                    Spacer()
                    Button(action: {
                        showLogsViewer = true
                    }) {
                        Image(systemName: "ladybug")
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        StorageClient.removeCustomerId()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                // Form Content
                ScrollView {
                    VStack(spacing: 16) {
                        // TextFields for input
                        CustomTextField(label: "Merchant Id", text: $viewModel.merchantId)
                        CustomTextField(label: "Terminal Id", text: $viewModel.terminalId)
                        CustomTextField(label: "Amount", text: $viewModel.amount)
                        CustomTextField(label: "Secret Key", text: $viewModel.secureHash)
                        CustomTextField(label: "Merchant Reference (Optional)", text: $viewModel.merchantReference)
                        
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
                                viewModel.transactionType = TransactionType(rawValue: newValue) ?? .CARD_WALLET
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
                        
                        // Color Pickers
                        ColorPickerRow(title: "Primary Color", selectedColor: $viewModel.primaryColor)
                        ColorPickerRow(title: "Secondary Color", selectedColor: $viewModel.secondaryColor)
                        
                        // Ignore Receipt Toggle
                        CustomToggle(title: "Ignore Receipt", isOn: $viewModel.ignoreReceipt)
                        
                        // Use Bottom Sheet Design Toggle
                        CustomToggle(title: "Use Bottom Sheet Design", isOn: $viewModel.useBottomSheetDesign)

                        Spacer(minLength: 16)

                        // Initiate Payment Button
                        Button(action: {
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
                }.padding(.horizontal)
            }
            .sheet(isPresented: $showLogsViewer) {
                LogsViewer()
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


// Color Picker Row Component
struct ColorPickerRow: View {
    var title: String
    @Binding var selectedColor: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 44, height: 44)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
        .padding(.bottom, 8)
    }
}

// Custom Toggle Component
struct CustomToggle: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
        .padding(.bottom, 8)
    }
}
