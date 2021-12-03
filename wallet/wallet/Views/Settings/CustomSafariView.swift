//
//  CustomSafariView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 02/11/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import SafariServices


struct CustomSafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomSafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<CustomSafariView>) {

    }

}
