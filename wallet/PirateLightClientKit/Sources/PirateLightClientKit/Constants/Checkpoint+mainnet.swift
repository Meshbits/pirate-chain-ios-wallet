//
//  WalletBirthday+mainnet.swift
//  PirateLightClientKit
//
//  Created by Francisco Gindre on 7/28/21.
//
import Foundation

extension Checkpoint {
    static let mainnetMin = Checkpoint(
        height: 152_855,
        hash: "00000001500922f7db74b9d82b745f84ebec28b0d5ea00d2a8af53207f3a63c1",
        time: 1544836549,
        saplingTree: "000000",
        orchardTree: nil
    )

    static let mainnetCheckpointDirectory = Bundle.module.bundleURL.appendingPathComponent("piratesaplingtree-checkpoints/mainnet/")
}
