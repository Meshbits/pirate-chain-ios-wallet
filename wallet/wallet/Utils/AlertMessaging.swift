//
//  AlertMessaging.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/10/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

extension UserFacingErrors {
    var title: String {
        switch self {
        case .initalizationFailed:
            return "Wallet Improperly Initialized".localized()
        case .synchronizerError:
            return "Processor Error".localized()
        case .connectionFailed:
            return "Connection Error".localized()
        case .transactionSubmissionError:
            return "Failed to Send".localized()
        case .internalError, .internalErrorWithMessage:
            return "Oops Something happened".localized()
        case .criticalError:
            return "Critical Error".localized()
        }
    }
    
    var message: String {
        switch self {
            
        case .initalizationFailed:
            return "This wallet has not been initialized correctly! Perhaps an error occurred during install. If you just created a new wallet close the app and retry.\n\n If this is an existing wallet, it can be fixed with a reset. First, locate your backup seed phrase, then \"Nuke Wallet\" and reimport it.".localized()
        case .synchronizerError:
            return "An error ocurred while syncing the blockchain. If the problem persists, back up your seed phrase and restore your wallet.".localized()
        case .connectionFailed:
            return "We are having problems with the network connection.".localized()
        case .transactionSubmissionError:
            return "We were unable to send your transaction. Your funds are safe, we just need to wait until the transaction expires before you can send them again.".localized()
        case .internalError(let error):
            return "We got this error: \(error.localizedDescription). :/"
        case .criticalError(let error):
            return "Error Description: \(error.debugDescription)"
        case .internalErrorWithMessage(let message):
            return "Hey! this error has something to say: \(message)."
        }
    }
}

extension UserFacingErrors: LocalizedError {
    public var errorDescription: String? {
        self.message
    }
}
