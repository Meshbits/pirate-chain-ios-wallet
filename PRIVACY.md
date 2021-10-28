No personal data is stored or collected by the Pirate Wallet application, except as necessary for authentication. All authentication encrypted data is stored locally.

The Pirate Wallet application uses the following permissions for the following reasons:

- **Internet Connectivity:** In order to fetch and post data and communicate with the blockchain through `lightwalletd` servers, the app requires internet connectivity. The signing of transactions is done locally and private keys are not shared over any network.

- **Access to Push Notifications:** In order to notify the user of important ongoing events while using the Pirate Wallet application, the Pirate Wallet application uses the local push notificiations on iOS.

- **Camera Access:** The Pirate Wallet application's QR code scanner is designed to read and parse Pirate chain address codes through the camera, and requires camera access to work properly. The user will be prompted to allow camera access upon first opening the address scan feature on sending screen.

- **Audio Play Permission:** Due to the current iOS limitations on running background processes for longer durations than 30 seconds, the Pirate Wallet application uses audio playback while background network sychronisation process is in progress.

- **Permission to vibrate the mobile device:** The Pirate Wallet application uses the vibration feature of the mobile device it is running on at various UI/UX actions, in order to give feedback upon those actions.

- **Biometric access:** The Pirate Wallet application also allows user to use biometric authentication, which includes FaceID and TouchID on iOS devices. If user chose to enable this setting in Pirate Wallet the wallet will prompt for Biometric authentication permissions for the application. This feature is optional and can be enabled or disabled at any time by user.
