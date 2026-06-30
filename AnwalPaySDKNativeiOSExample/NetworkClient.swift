//
//  NetworkClient.swift
//  AnwalPaySDKNativeiOSExample
//
//  Created by Ahmed Ganna on 09.02.25.
//


import Foundation
import UIKit
import CryptoKit
import amwalsdk

class NetworkClient {

    private var urlSession = URLSession.shared
    
    func fetchSessionToken(
        env: Config.Environment,
        merchantId: String,
        customerId: String?,
        secureHashValue: String,
        completion: @escaping (String?) -> Void
    ) {
        let webhookUrl: String
        switch env {
        case .SIT:
            webhookUrl = "https://test.amwalpg.com:24443/"
        case .UAT:
            webhookUrl = "https://test.amwalpg.com:14443/"
        case .PROD:
            webhookUrl = "https://webhook.amwalpg.com/"
        }
        
        // Async Network Call
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var dataMap: [String: Any?] = [
                    "merchantId": merchantId,
                    "customerId": customerId
                ]
                
                
                let secureHash = SecureHashUtil.clearSecureHash(secretKey: secureHashValue, data: &dataMap)
                
                var jsonBody: [String: Any] = [
                    "merchantId": merchantId,
                    "secureHashValue": secureHash,
                ]
                if((customerId) != nil){
                    jsonBody["customerId"] = customerId
                    
                }
                
                guard let url = URL(string: "\(webhookUrl)Membership/GetSDKSessionToken") else {
                    DispatchQueue.main.async {
                        self.showErrorDialog(message: "Invalid URL")
                        LogsManager.shared.addLog("Invalid URL: \(webhookUrl)Membership/GetSDKSessionToken", type: .error)
                        completion(nil)
                    }
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("text/plain", forHTTPHeaderField: "accept")
                request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "accept-language")
                request.addValue("application/json", forHTTPHeaderField: "content-type")

                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
                request.httpBody = jsonData

                let requestBodyString = String(data: jsonData, encoding: .utf8) ?? "<unreadable>"
                DispatchQueue.main.async {
                    LogsManager.shared.addLog(
                        "API Request -> \(request.httpMethod ?? "POST") \(url.absoluteString)\nHeaders: \(request.allHTTPHeaderFields ?? [:])\nBody: \(requestBodyString)",
                        type: .debug
                    )
                }

                let task = self.urlSession.dataTask(with: request) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.showErrorDialog(message: "Something Went Wrong")
                            LogsManager.shared.addLog("API Error -> \(url.absoluteString)\n\(error.localizedDescription)", type: .error)
                            completion(nil)
                        }
                        print("Error: \(error.localizedDescription)")
                        return
                    }

                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let rawBodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<empty>"
                    DispatchQueue.main.async {
                        LogsManager.shared.addLog(
                            "API Response <- \(url.absoluteString)\nStatus: \(statusCode)\nBody: \(rawBodyString)",
                            type: .debug
                        )
                    }

                    if let data = data, let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let success = response["success"] as? Bool, success {
                            if let data = response["data"] as? [String: Any], let sessionToken = data["sessionToken"] as? String {
                                DispatchQueue.main.async {
                                    LogsManager.shared.addLog("Session token parsed successfully", type: .info)
                                    completion(sessionToken)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    LogsManager.shared.addLog("Response missing sessionToken field", type: .error)
                                    self.showErrorDialog(message: "Unexpected response format")
                                    completion(nil)
                                }
                            }
                        } else {
                            let errorMessage = (response["errorList"] as? [String])?.joined(separator: ",") ?? "Unknown error"
                            DispatchQueue.main.async {
                                LogsManager.shared.addLog("API returned failure: \(errorMessage)", type: .error)
                                self.showErrorDialog(message: errorMessage)
                                completion(nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            LogsManager.shared.addLog("Failed to parse API response as JSON", type: .error)
                            self.showErrorDialog(message: "Something Went Wrong")
                            completion(nil)
                        }
                    }
                }

                task.resume()
                
            } catch {
                DispatchQueue.main.async {
                    LogsManager.shared.addLog("Failed to build request: \(error.localizedDescription)", type: .error)
                    self.showErrorDialog(message: "Something Went Wrong")
                    completion(nil)
                }
            }
        }
    }
    
    private func showErrorDialog(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if let topController = UIApplication.shared.keyWindow?.rootViewController {
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
