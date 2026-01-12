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
            return vc
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
