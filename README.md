# AnwalPaySDK for iOS

AnwalPaySDK is a powerful payment processing SDK for iOS applications that enables seamless integration of payment functionality. This SDK supports various payment methods including NFC, Card Wallet, and Apple Pay transactions.

## Requirements

- iOS 15.0 or later
- Xcode 13.0 or later
- CocoaPods

## Installation

1. Add the following line to your Podfile:

```ruby
# For development
pod 'amwalsdk'

# For release/archive builds
pod 'amwalsdk/Release'
```

2. Run the following command in your terminal:

```bash
pod install
```

3. Open your `.xcworkspace` file (not the `.xcodeproj` file)

## Usage

### Basic Implementation

1. Import the SDK in your Swift file:

```swift
import amwalsdk
```

2. Configure the payment parameters:

```swift
// First, fetch the session token
let networkClient = NetworkClient()
networkClient.fetchSessionToken(
    env: .UAT,  // Available options: .UAT, .PROD, .SIT
    merchantId: "YOUR_MERCHANT_ID",
    customerId: nil,  // Optional, only needed for saved card functionality
    secureHashValue: "YOUR_SECURE_HASH"
) { sessionToken in
    if let token = sessionToken {
        // Create the configuration with the session token
        let config = Config(
            environment: .UAT,  // Available options: .UAT, .PROD, .SIT
            sessionToken: token,
            currency: .OMR,     // Available options: .OMR, .USD, etc.
            amount: "AMOUNT",
            merchantId: "YOUR_MERCHANT_ID",
            terminalId: "YOUR_TERMINAL_ID",
            locale: .en,        // Available options: .en, .ar
            transactionType: .nfc,  // Available options: .nfc, .cardWallet, .applePay
            transactionId: Config.generateTransactionId(),  // Optional: Auto-generated if nil
            additionValues: Config.generateDefaultAdditionValues(),  // Optional: Custom key-value pairs
            merchantReference: "optional-merchant-reference"  // Optional: Merchant reference for transaction tracking
        )
        
        // Initialize and present the payment SDK
        let sdk = AmwalSDK()
        let viewController = try sdk.createViewController(
            config: config,
            onResponse: { response in
                // Handle the payment response
                print("Payment Response: \(response ?? "No response")")
            },
            onCustomerId: { customerId in
                // Handle the customer ID if needed
                print("Customer ID: \(customerId)")
            }
        )
        
        // Present the view controller
        self.present(viewController, animated: true)
    } else {
        print("Failed to fetch session token")
    }
}
```

3. For SwiftUI applications, use the SDKViewControllerRepresentable:

```swift
struct PaymentView: View {
    var body: some View {
        SDKViewControllerRepresentable(
            config: config,
            onResponse: { response in
                // Handle the payment response
                print("Payment Response: \(response ?? "No response")")
            },
            onCustomerId: { customerId in
                // Handle the customer ID if needed
                print("Customer ID: \(customerId)")
            }
        )
    }
}
```

### 4. Getting the SDK Session Token and Calculation of Secure Hash to call the API

# Endpoint to Fetch SDKSessionToken

## Environment URLs

### Stage
- **Base URL**: `https://test.amwalpg.com:14443`
- **Endpoint**: `Membership/GetSDKSessionToken`

### Production
- **Base URL**: `https://webhook.amwalpg.com`
- **Endpoint**: `Membership/GetSDKSessionToken`

---

## Description
This endpoint retrieves the SDK session token.

---

## Headers

| Header        | Value              |
|---------------|--------------------|
| Content-Type  | application/json   |

---

## Sample Request

```json
{
  "merchantId": 22914,
  "customerId": "ed520b67-80b2-4e1a-9b86-34208da10e53",
  "requestDateTime": "2025-02-16T12:43:51Z",
  "secureHashValue": "AFCEA6D0D29909E6ED5900F543739975B17AABA66CF2C89BBCCD9382A0BC6DD7"
}
```
## Sample Response

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "sessionToken": "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0..3yAPVR3evEwvIdq808M2uQ..."
  }
}
```

## SecureHash

### Overview
HMAC SHA256 hashing ensures data integrity and authenticity between systems.

---

### Prepare Request

1. Order key-value pairs **alphabetically**.
2. Join by `&`, removing the last `&`.
3. **Do not include** `secureHashValue` in the string.
4. Convert the resulting string to a byte array.
5. Generate a secure random key (at least 64 bits).
6. Concatenate the key and the data byte array.
7. Generate a **SHA256** hash.
8. Send the hash with the request as `secureHashValue`.

---

### Example

```json
{
  "merchantId": 22914,
  "customerId": "ed520b67-80b2-4e1a-9b86-34208da10e53", //optional, only to be used when using saved card functionality
  "requestDateTime": "2025-02-16T12:43:51Z",
  "secureHashValue": "AFCEA6D0D29909E6ED5900F543739975B17AABA66CF2C89BBCCD9382A0BC6DD7"
}
```
Example String to calculate Secure Hash using SHA-256 when not using customer ID = merchantID=22914&requestDatetime=2025-02-16T12:43:51Z
Example String to calculate Secure Hash using SHA-256 when using customer ID = customerID=123&merchantID=22914&requestDatetime=2025-02-16T12:43:51Z


### UUID Generation

If you need to generate a custom transaction ID, you can use the built-in UUID generator:

```swift
// Generate a UUID for transaction ID
let transactionId = Config.generateTransactionId()

// Or generate a custom UUID manually
let customUUID = UUID().uuidString.lowercased()
```

The UUID generator creates lowercase UUIDs ensuring compatibility with the payment system.

### Addition Values Configuration

The SDK supports `additionValues` parameter for passing custom key-value pairs that can be used for various SDK functionalities including UI customization and payment flow control. This is particularly important for Apple Pay configuration.

#### Default Addition Values

The SDK automatically provides default values:
- `merchantIdentifier`: "merchant.applepay.amwalpay" (used for Apple Pay configuration)

#### Available Configuration Options

##### UI Customization
- **`useBottomSheetDesign`**: `"true"` | `"false"` (default: `"false"`)
  - Controls the payment screen design
  - `"true"`: Uses the newer bottom sheet design (v2) - slides up from bottom covering 90% of screen
  - `"false"`: Uses the original full-screen design

- **`primaryColor`**: Hex color string (e.g., `"#FF5733"`)
  - Sets the primary theme color for the SDK UI

- **`secondaryColor`**: Hex color string (e.g., `"#33FF57"`)
  - Sets the secondary theme color for the SDK UI

##### Payment Flow
- **`ignoreReceipt`**: `"true"` | `"false"` (default: `"false"`)
  - Controls whether to show the receipt screen after transaction
  - `"true"`: Skips the receipt display
  - `"false"`: Shows the receipt screen

- **`merchantIdentifier`**: String (default: `"merchant.applepay.amwalpay"`)
  - Apple Pay merchant identifier for iOS

#### Apple Pay Specific Configuration

When implementing Apple Pay, the `merchantIdentifier` in `additionValues` must match your Apple Pay merchant ID configured in your Apple Developer account and Xcode project.

**Important**: The `merchantIdentifier` value in `additionValues` should match:
1. Your Apple Pay merchant ID from Apple Developer Portal
2. The merchant ID configured in Xcode under "Signing & Capabilities" → "Apple Pay"
3. The merchant ID registered with AnwalPay

#### Usage Examples

##### Example 1: Using Default Addition Values (for AnwalPay's default Apple Pay merchant)

```swift
let config = Config(
    environment: .UAT,
    sessionToken: token,
    currency: .OMR,
    amount: "100",
    merchantId: "your_merchant_id",
    terminalId: "your_terminal_id",
    locale: .en,
    transactionType: .applePay,
    transactionId: Config.generateTransactionId(),
    additionValues: Config.generateDefaultAdditionValues()
    // This generates: ["merchantIdentifier": "merchant.applepay.amwalpay"]
)
```

##### Example 2: Using Custom Apple Pay Merchant Identifier with UI Customization

```swift
// For your own Apple Pay merchant ID with bottom sheet design and colors
let customAdditionValues = [
    "merchantIdentifier": "merchant.com.yourcompany.applepay",
    "useBottomSheetDesign": "true",
    "primaryColor": "#FF5733",
    "secondaryColor": "#33FF57",
    "ignoreReceipt": "false"
]

let config = Config(
    environment: .UAT,
    sessionToken: token,
    currency: .OMR,
    amount: "100",
    merchantId: "your_merchant_id",
    terminalId: "your_terminal_id",
    locale: .en,
    transactionType: .applePay,
    transactionId: Config.generateTransactionId(),
    additionValues: customAdditionValues
)
```

##### Example 3: Minimal Configuration with Bottom Sheet Design

```swift
// Using just bottom sheet design with default colors
let minimalCustomValues = [
    "useBottomSheetDesign": "true"
]

let config = Config(
    environment: .UAT,
    sessionToken: token,
    currency: .OMR,
    amount: "100",
    merchantId: "your_merchant_id",
    terminalId: "your_terminal_id",
    locale: .en,
    transactionType: .cardWallet,
    transactionId: Config.generateTransactionId(),
    additionValues: minimalCustomValues
)
```

##### Example 4: Adding Additional Custom Values

```swift
// You can add more custom key-value pairs alongside merchantIdentifier
let extendedAdditionValues = [
    "merchantIdentifier": "merchant.com.yourcompany.applepay",
    "useBottomSheetDesign": "true",
    "primaryColor": "#7F22FF",
    "ignoreReceipt": "true"
]

let config = Config(
    environment: .UAT,
    sessionToken: token,
    currency: .OMR,
    amount: "100",
    merchantId: "your_merchant_id",
    terminalId: "your_terminal_id",
    locale: .en,
    transactionType: .applePay,
    transactionId: Config.generateTransactionId(),
    additionValues: extendedAdditionValues
)
```

**Note:** All boolean values should be passed as strings (`"true"` or `"false"`). Custom `additionValues` will be merged with defaults, with custom values taking precedence.
    terminalId: "your_terminal_id",
    locale: .en,
    transactionType: .nfc,  // or .cardWallet
    transactionId: Config.generateTransactionId(),
    additionValues: nil  // Optional for non-Apple Pay transactions
)
```

#### Available Methods

```swift
// Generate default addition values (includes default Apple Pay merchant identifier)
let defaultValues = Config.generateDefaultAdditionValues()
// Returns: ["merchantIdentifier": "merchant.applepay.amwalpay"]

// Generate a transaction ID
let transactionId = Config.generateTransactionId()
// Returns: A lowercase UUID string (e.g., "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
```

#### Key Points for Apple Pay Integration

1. **Merchant Identifier Consistency**: Ensure the `merchantIdentifier` in `additionValues` matches your Apple Pay configuration
2. **Required for Apple Pay**: The `merchantIdentifier` key is mandatory when using `transactionType: .applePay`
3. **Optional for Other Payment Types**: For NFC and Card Wallet transactions, `additionValues` can be nil or contain custom tracking data
4. **Case Sensitive**: The key name `merchantIdentifier` is case-sensitive
5. **Format**: Apple Pay merchant identifiers typically follow the format: `merchant.com.yourcompany.identifier`

### Configuration Options

#### Currency
- OMR (Omani Rial)

#### Language
- en (English)
- ar (Arabic)

#### Environment
- UAT (Testing environment)
- PROD (Production environment)

#### Transaction Types
- NFC (Near Field Communication)
- CARD_WALLET (Card Wallet payments)
- APPLE_PAY (Apple Pay integration)

### Apple Pay Requirements

When using Apple Pay transactions, you must:

1. Enable Apple Pay capability in your Xcode project:
   - Open your project in Xcode
   - Select your target
   - Go to "Signing & Capabilities"
   - Click "+" and add "Apple Pay"
   - Configure your merchant ID in the capability settings

2. Share your Apple Pay merchant ID with AnwalPay:
   - Contact our support team
   - Provide your Apple Pay merchant ID
   - We will configure our systems to accept payments from your merchant ID

## Security

The SDK implements secure hash generation for transaction validation. Make sure to:
1. Keep your secret key secure
2. Generate the secure hash on your server
3. Never expose sensitive credentials in your client-side code

## Example

Check out the example project in the repository to see a complete implementation of the SDK.

## Support

For technical support or questions, please contact:
- Email: support@anwal-pay.com
- Website: https://www.amwal-pay.com/

## License

This SDK is proprietary software. All rights reserved.

Copyright © 2024 AnwalPay. All rights reserved. 
