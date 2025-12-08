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
        print("🌐 [NetworkClient] Starting session token request...")
        print("   • Environment: \(env)")
        print("   • Merchant ID: \(merchantId)")
        print("   • Customer ID: \(customerId ?? "nil")")
        print("   • Secure Hash: \(secureHashValue.prefix(8))...")
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
                print("🚀 [SESSION TOKEN REQUEST] Starting session token fetch...")
                print("🌍 Environment: \(env)")
                print("🔗 Base URL: \(webhookUrl)")
                
                // Generate current datetime in ISO 8601 format
                let dateFormatter = ISO8601DateFormatter()
                let requestDateTime = dateFormatter.string(from: Date())
                print("⏰ Request DateTime: \(requestDateTime)")
                
                // Clean up customerId - treat "null" string as nil
                let cleanCustomerId: String? = {
                    guard let id = customerId, id != "null", !id.isEmpty else {
                        return nil
                    }
                    return id
                }()
                
                print("👤 Customer ID (cleaned): \(cleanCustomerId ?? "nil")")
                
                var dataMap: [String: Any?] = [
                    "merchantId": merchantId,
                    "requestDateTime": requestDateTime
                ]
                
                // Only include customerId if it's not nil
                if let cleanCustomerId = cleanCustomerId {
                    dataMap["customerId"] = cleanCustomerId
                }
                
                print("📝 Data for secure hash calculation: \(dataMap)")
                
                let secureHash = SecureHashUtil.clearSecureHash(secretKey: secureHashValue, data: &dataMap)
                print("🔐 Generated secure hash: \(secureHash)")
                
                var jsonBody: [String: Any] = [
                    "merchantId": merchantId,
                    "requestDateTime": requestDateTime,
                    "secureHashValue": secureHash,
                ]
                
                // Only include customerId in request body if it's not nil
                if let cleanCustomerId = cleanCustomerId {
                    jsonBody["customerId"] = cleanCustomerId
                }
                
                print("📤 Request body: \(jsonBody)")
                
                guard let url = URL(string: "\(webhookUrl)Membership/GetSDKSessionToken") else {
                    print("❌ Invalid URL: \(webhookUrl)Membership/GetSDKSessionToken")
                    DispatchQueue.main.async {
                        self.showErrorDialog(message: "Invalid URL")
                        completion(nil)
                    }
                    return
                }
                
                print("🎯 Full URL: \(url.absoluteString)")
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("text/plain", forHTTPHeaderField: "accept")
                request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "accept-language")
                request.addValue("application/json", forHTTPHeaderField: "content-type")
                
                print("📋 Request headers:")
                if let headers = request.allHTTPHeaderFields {
                    for (key, value) in headers {
                        print("   \(key): \(value)")
                    }
                }
                
                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
                request.httpBody = jsonData
                
                print("📦 Request body size: \(jsonData.count) bytes")
                if let bodyString = String(data: jsonData, encoding: .utf8) {
                    print("📄 Request body JSON:\n\(bodyString)")
                }
                
                let task = self.urlSession.dataTask(with: request) { data, response, error in
                    print("\n🌐 [NetworkClient] Received response")
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("   • Status Code: \(httpResponse.statusCode)")
                        if let headers = httpResponse.allHeaderFields as? [String: Any] {
                            print("   • Response Headers: \(headers)")
                        }
                    }
                    
                    if let error = error {
                        print("❌ [NetworkClient] Network error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.showErrorDialog(message: "Network Error: \(error.localizedDescription)")
                            completion(nil)
                        }
                        return
                    }
                    
                    guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                        print("❌ [NetworkClient] No data received or invalid data format")
                        DispatchQueue.main.async {
                            self.showErrorDialog(message: "No data received from server")
                            completion(nil)
                        }
                        return
                    }
                    
                    print("📦 [NetworkClient] Raw response: \(responseString)")
                    
                    do {
                        guard let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            print("❌ Failed to parse JSON response")
                            DispatchQueue.main.async {
                                self.showErrorDialog(message: "Invalid JSON response from server")
                                completion(nil)
                            }
                            return
                        }
                        
                        print("📊 Parsed response: \(response)")
                        
                        if let success = response["success"] as? Bool {
                            print("✅ Success flag: \(success)")
                            
                            if success {
                                if let data = response["data"] as? [String: Any], let sessionToken = data["sessionToken"] as? String {
                                    print("🎉 Session token received successfully!")
                                    print("🔑 Session token: \(sessionToken.prefix(20))...")
                                    DispatchQueue.main.async {
                                        completion(sessionToken)
                                    }
                                } else {
                                    print("❌ Session token not found in response data")
                                    print("❌ Response data: \(response["data"] ?? "nil")")
                                    DispatchQueue.main.async {
                                        self.showErrorDialog(message: "Session token not found in response")
                                        completion(nil)
                                    }
                                }
                            } else {
                                let errorMessage = (response["errorList"] as? [String])?.joined(separator: ",") ?? "Unknown error"
                                let message = response["message"] as? String ?? "No message"
                                print("❌ API Error - Success: false")
                                print("❌ Error message: \(message)")
                                print("❌ Error list: \(errorMessage)")
                                DispatchQueue.main.async {
                                    self.showErrorDialog(message: "API Error: \(message) - \(errorMessage)")
                                    completion(nil)
                                }
                            }
                        } else {
                            print("❌ No success field found in response")
                            DispatchQueue.main.async {
                                self.showErrorDialog(message: "Invalid response format - missing success field")
                                completion(nil)
                            }
                        }
                    } catch {
                        print("❌ JSON parsing error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.showErrorDialog(message: "JSON parsing error: \(error.localizedDescription)")
                            completion(nil)
                        }
                    }
                }
                
                print("🚀 Sending request...")
                task.resume()
                
            } catch {
                print("❌ Request preparation error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorDialog(message: "Request preparation error: \(error.localizedDescription)")
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
