# zcash-ios-wallet

[![Build Status](https://travis-ci.org/zcash/zcash-ios-wallet.svg?branch=master)](https://travis-ci.org/zcash/zcash-ios-wallet)


# Motivation
Dogfooding - _transitive verb_ - is the practice of an organization using its own product. This app was created to help us learn.

Please take note: the wallet is not an official product by ECC, but rather a tool for learning about our libraries that it is built on. This means that we do not have robust infrastructure or user support for this application. We open sourced it as a resource to make wallet development easier for the Zcash ecosystem.

# Disclaimers
There are some known areas for improvement:

- This app is mainly intended for learning and improving the related libraries that it uses. There may be bugs.
- Traffic analysis, like in other cryptocurrency wallets, can leak some privacy of the user.
- The wallet requires a trust in the server to display accurate transaction information. 

See the [Wallet App Threat Model](https://zcash.readthedocs.io/en/latest/rtd_pages/wallet_threat_model.html)
for more information about the security and privacy limitations of the wallet.

If you'd like to sign up to help us test, reach out on discord and let us know! We're always happy to get feedback!

# Description

iOS wallet using the Zcash iOS SDK that is maintained by core developers.

This a reference wallet for the following set of features:
- z2z transactions w/ encrypted memos
- reply-to formatted memos
- z2t transactions
- transparent receive-only
- autoshielding on threshold from receive only t-address

note: z means sapling shielded addresses.
# Prerequisites
* make sure you can build ZcashLightClientKit Demo Apps successfully

# Building the App
1. Clone the project, make sure you have the latest Xcode Version

2. Create `env-vars.sh file` at `${SRCROOT}` [See Instructions](https://github.com/zcash/ZcashLightClientKit#setting-env-varsh-file-to-run-locally)

3. Navigate to the wallet directory where the `Podfile` file is located and run `pod install`

4. open the `ECC-Wallet.xcworkspace` file

## Or use these commands

```shell
git clone https://github.com/meshbits/pirate-chain-ios-wallet -b arrr-1.0
cd pirate-chain-ios-wallet/wallet/
cp env-vars.sh.example env-vars.sh
./reset.sh
open ECC-Wallet.xcworkspace
```

**NOTE: Use `wallet-no-logging` to build the app.**

**IMPORTANT:** If you are switching to try building the app between a simulator and physical device, each time execute `./reset.sh`. For some reason the zcash library isn't compiled universal and has to use this workaround to build it properly for either simular or physical device.

5. build and run on simulator.

If you had problems in any of these steps please check the [troubleshooting document](/TROUBLESHOOTING.md)
# Enabling/Disabling logging Features

This is our internal dogfooding app, and we implemented some level of event logging to be able to study user interactions and improve the User Experience with Zcash on mobile devices.

## No logs please

*You can build and run the app **without it** by using the `wallet-no-logging`*

The "no logging" target does not even build or include the Mixpanel sdk on your build or any code related with it. You can make sure of this by looking at the code yourself. If you think there's a better way achieve this, please open an Issue with your proposal. :-) 

## I want to use Mixpanel

If you wish to use mixpanel in your own build, make sure to include the following line in your env-vars.sh file
`export MIXPANEL_TOKEN="YOUR_TOKEN"`
And build the `wallet` target. Sourcery will pick it up and generate the Constants.generated.swift file that the Mixpanel SDK will use to send the events to your board

## I use some other kind of tracker...
that I would like to include in my project. The app does not care about the details of the event logger as long as it implements this protocol
````Swift
protocol EventLogging {
    func track(_ event: LogEvent, properties: KeyValuePairs<String, String>)
}
````

You can implement your own tracker proxy

# Support for Deep Links:

msg or message key should have the message for the transaction (optional)
and amount, tx_amount - you can use either of these to specify the amount while generating the qr code that needs to be parsed by wallet.

arrr://175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz
arrr://175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?tx_amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz
arrr://175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?tx_amount=50&label=Luke-Jr&msg=Donation%20for%20project%20xyz

pirate://175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz
pirate://175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?tx_amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz
pirate://175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?tx_amount=50&label=Luke-Jr&msg=Donation%20for%20project%20xyz

# Contributing

Contributions are very much welcomed! Please read our [Contributing Guidelines](/CONTRIBUTING.md) and [Code of Conduct](/CONDUCT.md). Our backlog has many Issues tagged with the `good first issue` label. Please fork the repo and make a pull request for us to review.

# Reporting an issue

If you wish to report a security issue, please follow our [Responsible Disclosure guidelines](https://github.com/zcash/ZcashLightClientKit/blob/master/responsible_disclosure.md).

 For other kind of inquiries, feel welcome to open an Issue if you encounter a bug or would like to request a feature.

 # License

 MIT
