//
//  FlutterViewControllerRepresentable.swift
//  AnwalPaySDKNativeiOSExample
//
//  Created by Ahmed Ganna on 09.02.25.
//


import SwiftUI
import Flutter
import amwalsdk

struct SDKViewControllerRepresentable: UIViewControllerRepresentable {
    var config: Config
    var onResponse: (String?) -> Void
    var onCustomerId: (String) -> Void
        
    func makeUIViewController(context: Context) -> UIViewController {
        do {
            // Create the FlutterViewController using AmwalSDK
            let sdk = AmwalSDK()
            let vc = try sdk.createViewController(
                config: config,
                onResponse: onResponse,
                onCustomerId: onCustomerId
            )
            // Ensure transparency
            vc.view.backgroundColor = .clear
            vc.view.isOpaque = false
            
            // Use a custom container that can handle share sheet presentation
            let containerVC = ShareableContainerViewController(flutterVC: vc)
            containerVC.view.backgroundColor = .clear
            containerVC.modalPresentationStyle = .overFullScreen
            
            return containerVC
        } catch {
            // Handle the error if creation fails (e.g., show a default or error view)
            print("Error creating FlutterViewController: \(error.localizedDescription)")
            let errorView = UIViewController()
            errorView.view.backgroundColor = .clear
            return errorView
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Handle updates to the UI if needed
        uiViewController.view.backgroundColor = .clear
        uiViewController.view.isOpaque = false
    }
}

/// Custom container view controller that properly handles share sheet presentation
/// by finding the topmost presented view controller
class ShareableContainerViewController: UIViewController {
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
        
        // Add Flutter view controller as child
        addChild(flutterVC)
        view.addSubview(flutterVC.view)
        flutterVC.view.frame = view.bounds
        flutterVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        flutterVC.didMove(toParent: self)
        
        view.backgroundColor = .clear
        flutterVC.view.backgroundColor = .clear
        
        // Set this view controller as the presentation context
        definesPresentationContext = true
        providesPresentationContextTransitionStyle = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Override the share presentation to use the topmost view controller
        setupSharePresentationOverride()
    }
    
    private func setupSharePresentationOverride() {
        // This ensures that when share_plus tries to present,
        // it will find the correct view controller
    }
    
    /// Find the topmost presented view controller in the hierarchy
    private func topmostPresentedViewController() -> UIViewController {
        var topController: UIViewController = self
        while let presented = topController.presentedViewController {
            topController = presented
        }
        return topController
    }
    
    /// Override to handle presentation from the correct view controller
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        // If we're already presenting something, present from the topmost controller
        if let presented = presentedViewController {
            let topmost = topmostPresentedViewController()
            topmost.present(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}
