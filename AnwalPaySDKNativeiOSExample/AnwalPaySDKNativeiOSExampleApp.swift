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
            ZStack {
                NavigationStack {
                    FormView(onSubmit: { viewModel in
                        startSdk(viewModel: viewModel)
                    })
                }
                
                // Overlay the SDK instead of using fullScreenCover
                // This allows the SDK to present share sheets properly
                if showSDK, let config = config {
                    SDKOverlayView(
                        config: config,
                        onDismiss: {
                            showSDK = false
                            self.config = nil
                        },
                        onCustomerId: { customerId in
                            StorageClient.saveCustomerId(customerId)
                        }
                    )
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showSDK)
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
            }
        }
    }
}

/// Overlay view that presents the SDK without using modal presentation
/// This allows the SDK to present share sheets and other modals properly
struct SDKOverlayView: View {
    let config: Config
    let onDismiss: () -> Void
    let onCustomerId: (String) -> Void
    
    var body: some View {
        SDKViewControllerWrapper(
            config: config,
            onResponse: { _ in
                onDismiss()
            },
            onCustomerId: onCustomerId
        )
        .ignoresSafeArea()
        .background(Color.black.opacity(0.01)) // Minimal background to capture taps
    }
}

/// UIViewControllerRepresentable that presents the SDK in its own window
/// This avoids the "already presenting" issue
struct SDKViewControllerWrapper: UIViewControllerRepresentable {
    var config: Config
    var onResponse: (String?) -> Void
    var onCustomerId: (String) -> Void
    
    func makeUIViewController(context: Context) -> SDKWindowViewController {
        return SDKWindowViewController(
            config: config,
            onResponse: onResponse,
            onCustomerId: onCustomerId
        )
    }
    
    func updateUIViewController(_ uiViewController: SDKWindowViewController, context: Context) {
        // No updates needed
    }
}

/// View controller that creates a new window for the SDK
/// This ensures the SDK has its own presentation context
class SDKWindowViewController: UIViewController {
    private var sdkWindow: UIWindow?
    private let config: Config
    private let onResponse: (String?) -> Void
    private let onCustomerId: (String) -> Void
    
    init(config: Config, onResponse: @escaping (String?) -> Void, onCustomerId: @escaping (String) -> Void) {
        self.config = config
        self.onResponse = onResponse
        self.onCustomerId = onCustomerId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSDKInNewWindow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissSDKWindow()
    }
    
    private func presentSDKInNewWindow() {
        guard sdkWindow == nil else { return }
        
        // Get the current window scene
        guard let windowScene = view.window?.windowScene else {
            print("No window scene available")
            return
        }
        
        // Create a new window for the SDK
        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = .normal + 1
        window.backgroundColor = .clear
        
        do {
            let sdk = AmwalSDK()
            let flutterVC = try sdk.createViewController(
                config: config,
                onResponse: { [weak self] response in
                    self?.onResponse(response)
                    self?.dismissSDKWindow()
                },
                onCustomerId: onCustomerId
            )
            
            flutterVC.view.backgroundColor = .clear
            
            // Create a container that can handle presentations
            let containerVC = SDKContainerVC(flutterVC: flutterVC)
            containerVC.view.backgroundColor = .clear
            
            window.rootViewController = containerVC
            window.makeKeyAndVisible()
            
            self.sdkWindow = window
            
        } catch {
            print("Error creating Flutter view controller: \(error)")
        }
    }
    
    private func dismissSDKWindow() {
        sdkWindow?.isHidden = true
        sdkWindow?.rootViewController = nil
        sdkWindow = nil
    }
}

/// Container view controller for the SDK that properly handles presentation
class SDKContainerVC: UIViewController {
    private let flutterVC: UIViewController
    
    init(flutterVC: UIViewController) {
        self.flutterVC = flutterVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(flutterVC)
        view.addSubview(flutterVC.view)
        flutterVC.view.frame = view.bounds
        flutterVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        flutterVC.didMove(toParent: self)
        
        view.backgroundColor = .clear
        definesPresentationContext = true
    }
}
