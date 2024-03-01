//
//  GetBalanceViewController.swift
//  PirateLightClientSample
//
//  Created by Francisco Gindre on 11/26/19.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import UIKit
import PirateLightClientKit

class GetBalanceViewController: UIViewController {
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var verified: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let synchronizer = AppDelegate.shared.sharedSynchronizer
        self.title = "Account Balance"

        Task { @MainActor in
            let balanceText = (try? await synchronizer.getShieldedBalance().decimalString()) ?? "0.0"
            let verifiedText = (try? await synchronizer.getShieldedVerifiedBalance().decimalString()) ?? "0.0"
            self.balance.text = "\(balanceText) ARRR"
            self.verified.text = "\(verifiedText) ARRR"
        }
    }
}

extension Zatoshi {
    var formattedString: String? {
        NumberFormatter.zcashNumberFormatter.string(from: NSNumber(value: self.amount))
    }
}
