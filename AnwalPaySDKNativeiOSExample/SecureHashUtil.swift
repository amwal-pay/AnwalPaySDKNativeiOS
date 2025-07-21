import Foundation
import CommonCrypto

class SecureHashUtil {

    /// Removes `secureHashValue`, composes the data, and generates a secure hash.
    static func clearSecureHash(secretKey: String, data: inout [String: Any?]) -> String {
        print("🔒 [SECURE HASH] Starting secure hash calculation...")
        print("🔑 Secret key length: \(secretKey.count) characters")
        print("📊 Input data before processing: \(data)")
        
        data.removeValue(forKey: "secureHashValue")
        print("📊 Data after removing secureHashValue: \(data)")
        
        let concatenatedString = composeData(requestParameters: data)
        print("📝 Concatenated string for hashing: '\(concatenatedString)'")
        
        let hash = generateSecureHash(message: concatenatedString, secretKey: secretKey)
        print("🔐 Generated secure hash: \(hash)")
        
        return hash
    }

    /// Composes the data into a sorted and concatenated string.
    private static func composeData(requestParameters: [String: Any?]) -> String {
        guard !requestParameters.isEmpty else { 
            print("⚠️ Empty request parameters")
            return "" 
        }

        // Sort parameters by key in ascending order and remove nil values
        let sortedParameters = requestParameters
            .filter { $0.value != nil } // Remove entries with nil values
            .sorted { $0.key < $1.key }

        print("📋 Sorted parameters: \(sortedParameters)")

        // Join key-value pairs into a single string
        let result = sortedParameters
            .map { "\($0.key)=\($0.value!)" } // Safely unwrap since nil values are removed
            .joined(separator: "&")
            
        print("🔗 Composed data string: '\(result)'")
        return result
    }

    /// Generates a secure hash using HMAC-SHA256.
    private static func generateSecureHash(message: String, secretKey: String) -> String {
        print("🔐 [HMAC-SHA256] Generating hash...")
        print("📝 Message: '\(message)'")
        print("🔑 Secret key (first 10 chars): '\(String(secretKey.prefix(10)))...'")
        
        guard let keyData = secretKey.hexToBytes() else { 
            print("❌ Failed to convert secret key to bytes")
            return "" 
        }
        
        print("🔢 Key data length: \(keyData.count) bytes")
        
        guard let messageData = message.data(using: .utf8) else { 
            print("❌ Failed to convert message to UTF-8 data")
            return "" 
        }
        
        print("📦 Message data length: \(messageData.count) bytes")

        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyData.withUnsafeBytes { keyBytes in
            messageData.withUnsafeBytes { messageBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes.baseAddress, keyBytes.count, messageBytes.baseAddress, messageBytes.count, &digest)
            }
        }

        let result = digest.map { String(format: "%02x", $0) }.joined().uppercased()
        print("✅ Generated hash: \(result)")
        return result
    }
}

// MARK: - Helper Extension
extension String {
    /// Converts a hexadecimal string to a byte array.
    func hexToBytes() -> [UInt8]? {
        var hex = self
        if hex.count % 2 != 0 {
            hex = "0" + hex // Ensure even-length string
        }

        var bytes = [UInt8]()
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            if let byte = UInt8(hex[index..<nextIndex], radix: 16) {
                bytes.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
}
