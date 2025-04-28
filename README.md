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
let config = PaymentConfig(
    merchantId: "YOUR_MERCHANT_ID",
    terminalId: "YOUR_TERMINAL_ID",
    amount: "AMOUNT",
    currency: .OMR,  // Available options: OMR, USD, etc.
    language: .en,   // Available options: en, ar
    environment: .UAT, // Available options: UAT, PROD
    secureHash: "YOUR_SECURE_HASH",
    transactionType: .nfc // Available options: .nfc, .cardWallet, .applePay
)
```

3. Initialize and present the payment SDK:

```swift
let paymentSDK = AnwalPaySDK(config: config)
paymentSDK.present(from: self) { result in
    switch result {
    case .success(let transaction):
        // Handle successful transaction
        print("Transaction ID: \(transaction.id)")
    case .failure(let error):
        // Handle error
        print("Error: \(error.localizedDescription)")
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
