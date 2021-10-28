No personal data is stored or collected by the Pirate Wallet application, except as necessary for authentication. All authentication data is stored locally.

The Pirate Wallet application uses the following permissions for the following reasons:

- **Internet connectivity:** In order to fetch and post data and communicate with the blockchain through `lightwalletd` servers, the app requires internet connectivity. The signing of transactions is done locally and private keys are not shared over any network.

- **Access to system alerts:** In order to notify the user of important ongoing events while using the Pirate Wallet application, the Pirate Wallet application uses the system alert framework on iOS.

- **Camera access:** The Pirate Wallet application's QR code scanner is designed to read and parse Pirate chain address codes through the camera, and requires camera access to work properly. The user will be prompted to allow camera access upon first opening the address scan feature on sending screen.

- **Audio access:** Due to the current iOS limitations on running background processes for longer durations than 30 seconds, the Pirate Wallet application uses audio playback while background network sychronisation process is in progress.

- **Permission to vibrate the mobile device:** The Pirate Wallet application uses the vibration feature of the mobile device it is running on at various UI/UX actions, in order to give feedback upon those actions.
