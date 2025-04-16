# AnwalPaySDK for iOS

AnwalPaySDK is a powerful payment processing SDK for iOS applications that enables seamless integration of payment functionality. This SDK supports various payment methods including NFC transactions.

## Requirements

- iOS 15.0 or later
- Xcode 13.0 or later
- CocoaPods

## Installation

1. Add the following line to your Podfile:

```ruby
pod 'amwalsdk'
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
    secureHash: "YOUR_SECURE_HASH"
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
- NFC
- Other supported payment methods

## Security

The SDK implements secure hash generation for transaction validation. Make sure to:
1. Keep your secret key secure
2. Generate the secure hash on your server
3. Never expose sensitive credentials in your client-side code

## Example

Check out the example project in the repository to see a complete implementation of the SDK.

## Support

For technical support or questions, please contact:
- Email: support@amwal-pay.com
- Website: https://www.amwal-pay.com/

## License

This SDK is proprietary software. All rights reserved.

Copyright © 2024 AnwalPay. All rights reserved. 