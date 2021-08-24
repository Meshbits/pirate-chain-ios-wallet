//
//  QRCodeImagePicker.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 22/06/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

public struct QRCodeImagePicker: UIViewControllerRepresentable {

    private let sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode

    public init(sourceType: UIImagePickerController.SourceType, onImagePicked: @escaping (UIImage) -> Void) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void

        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.onImagePicked(image)
            }
            self.onDismiss()
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }

    }

}
