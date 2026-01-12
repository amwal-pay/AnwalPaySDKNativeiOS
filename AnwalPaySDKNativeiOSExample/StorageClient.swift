//
//  StorageClient.swift
//  AnwalPaySDKNativeiOSExample
//
//  Created by Kiro on 07.12.25.
//

import Foundation

class StorageClient {
    private static let defaults = UserDefaults.standard
    private static let customerIdKey = "customer_id"
    
    static func saveCustomerId(_ customerId: String?) {
        if let customerId = customerId {
            defaults.set(customerId, forKey: customerIdKey)
        } else {
            defaults.removeObject(forKey: customerIdKey)
        }
    }
    
    static func getCustomerId() -> String? {
        return defaults.string(forKey: customerIdKey)
    }
    
    static func removeCustomerId() {
        defaults.removeObject(forKey: customerIdKey)
    }
}
