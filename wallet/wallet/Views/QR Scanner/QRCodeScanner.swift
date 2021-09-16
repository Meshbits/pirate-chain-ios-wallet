//
//  QRCodeScanner.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 11/06/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import AVFoundation
extension Notification.Name {
    static let qrCodeScanned = Notification.Name(rawValue: "qrCodeScanned")
}

class QRCodeScanAddressViewModel: ObservableObject {
    let addressPublisher = PassthroughSubject<String,Never>()
    let scannerDelegate = CombineAdapter()
    var dispose = Set<AnyCancellable>()
    var shouldShowSwitchButton: Bool = true
    var showCloseButton: Bool = false
    @Published var showInvalidAddressMessage: Bool = false
    @Published var showValidAddressMessage: Bool = false
    init(shouldShowSwitchButton: Bool, showCloseButton: Bool) {
        self.shouldShowSwitchButton = shouldShowSwitchButton
        self.showCloseButton = showCloseButton
        
        self.scannerDelegate.publisher.receive(on: DispatchQueue.main)
            .removeDuplicates(by: { $0 == $1 })
            .sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                print(error)
                logger.error("\(error)")
            case .finished:
                logger.debug("finished")
            }
        }) { (address) in
            self.parseAnAddress(address: address)
        }.store(in: &dispose)
    }
    
    func parseAnAddress(address:String){
        
        // TODO - Fix in the pirate chain payment URI Library needed to support
        //Module compiled with Swift 5.3.2 cannot be imported by the Swift 5.4.2 compiler:
        // If there is pirate chain payment URI
        if let pirateChainPaymentURI = PirateChainPaymentURI.parse(address) {

            // Check if pirate chain payment address is not nil
            guard let pirateChainAddress = pirateChainPaymentURI.address else {
                self.showInvalidAddressMessage = true
                return
            }

            // Check if there is valid shielded pirate chain payment address
            guard ZECCWalletEnvironment.shared.isValidAddress(pirateChainAddress) else {
                self.showInvalidAddressMessage = true
                return
            }

            self.showInvalidAddressMessage = true
            self.showValidAddressMessage = true
            PasteboardAlertHelper.shared.copyToPasteBoard(value: address, notify: "feedback_addresscopied".localized())
//                self.scannerDelegate.publisher.send(address)

        }else{
            // If there is valid shielded address then proceed otherwise don't
            guard ZECCWalletEnvironment.shared.isValidAddress(address) else {
                self.showInvalidAddressMessage = true
                return
            }

            self.showInvalidAddressMessage = true
            self.showValidAddressMessage = true
            PasteboardAlertHelper.shared.copyToPasteBoard(value: address, notify: "feedback_addresscopied".localized())
//                self.scannerDelegate.publisher.send(address)
        }

    }
  
}

struct QRCodeScanner: View {
    @EnvironmentObject var environment: ZECCWalletEnvironment
    @ObservedObject var viewModel: QRCodeScanAddressViewModel
    @State var cameraAccess: CameraAccessHelper.Status
    @Binding var isScanAddressShown: Bool
    @State var wrongAddressScanned = false
    @State var torchEnabled: Bool = false
    @State var image: UIImage?
    @State var openImagePicker: Bool = false

    @Environment(\.presentationMode) var presentationMode:Binding<PresentationMode>
    var scanFrame: some View {
        Image("QRCodeScanFrame")
            .padding()
    }
    
    var torchButton: AnyView {
        guard torchAvailable else { return AnyView(EmptyView()) }
        return AnyView(
            Button(action: {
                self.toggleTorch(on: !self.torchEnabled)
                tracker.track(.tap(action: .scanTorch),
                              properties: ["value" : String(!self.torchEnabled)])
                self.torchEnabled.toggle()
            }) {
                Image("bolt")
                    .renderingMode(.template)
            }
        )
    }
    
    var galleryButton: AnyView {

        return AnyView(
            Button(action: {
                self.openImagePicker.toggle()
            }) {
                Image("QRCodeIcon")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .colorMultiply(.white)
                    .frame(width: 26, height: 26)
                    .padding()
                
            }
        )
    }
    
    
    
    var authorized: some View {
          ZStack {
            QRCodeScannerView(delegate: viewModel.scannerDelegate)
                .edgesIgnoringSafeArea(.all).onAppear {
                    NotificationCenter.default.post(name: .resumeRecordingIfPaused, object: nil)
                }.onDisappear {
                    NotificationCenter.default.post(name: .pauseVideoRecording, object: nil)
                }
            
            VStack {
                Spacer()
                VStack {
                    scanFrame
                    Text(viewModel.showValidAddressMessage ? "Copied Valid Scanned Address to Clipboard".localized() : "scan_invalidQR".localized())
                        .bold()
                        .foregroundColor(.white)
                        .opacity(self.wrongAddressScanned ? 1 : 0)
                        .animation(.easeInOut)
                        .onReceive(viewModel.$showInvalidAddressMessage) { (value) in
                            
                            guard value else { return }
                            self.wrongAddressScanned = true
                            DeviceFeedbackHelper.vibrate()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.wrongAddressScanned = false
                        }
                        }.onReceive(viewModel.$showValidAddressMessage) { (value) in
                            guard value else { return }
                            DeviceFeedbackHelper.vibrate()
                               DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                   presentationMode.wrappedValue.dismiss()
                               }
                       }
                }
                Spacer()
            }
        }
    }
    
    var unauthorized: some View {
         ZStack {
            ZcashBackground()
            VStack {
                Spacer()
                ZStack {
                    scanFrame
                    Text("We don't have permission to access your camera".localized())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.all, 36)
                }
                Spacer()
                
                Button(action: {}){
                    ZcashButton(text: "scan_cameraunallowed".localized())
                        .frame(height: 50)
                }
                .padding()
            }
        }
    }
    
    var restricted: some View {
          ZStack {
            ZcashBackground()
            VStack {
             
                ZStack {
                    scanFrame
                    Text("scan_cameraunavaliable".localized())
                        .foregroundColor(.white)
                }
            }
        }
    }

    
    func viewFor(state: CameraAccessHelper.Status) -> some View {
        switch state {
        case .authorized, .undetermined:

            let auth = authorized.navigationBarTitle("Scan QR Code".localized(), displayMode: .inline)
            
            if viewModel.showCloseButton {
                return AnyView(
                    auth.navigationBarItems(leading:torchButton, trailing:  ZcashCloseButton(action: {
                        tracker.track(.tap(action: .scanBack), properties: [:])
                            self.isScanAddressShown = false
                    }).frame(width: 30, height: 30))
                )
            }
            return AnyView(
                auth.navigationBarItems(
                    trailing: HStack(spacing: 5, content: {
                        torchButton
                        galleryButton
                    })
                )
            )
        case .unauthorized:
            return AnyView(unauthorized)
        case .unavailable:
            return AnyView(restricted)
        }
        
    }
    
    var body: some View {
        viewFor(state: cameraAccess)
        .onDisappear() {
            self.toggleTorch(on: false)
        }
        .onAppear() {
            tracker.track(.screen(screen: .scan), properties: [:])
        }.sheet(isPresented: $openImagePicker) {
            QRCodeImagePicker(sourceType: .photoLibrary) { image in
                self.image = image
                self.scanQRCodeFromAnImage()
            }
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//
//            }
        }
    }
    
    func scanQRCodeFromAnImage(){

        // Checking if it's a valid image

        if let mSelectedImage = self.image {
            
            // Parsing QR Code from an image
            
            let ciDetectorObj:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
                                    
            let ciImage:CIImage = CIImage(image:mSelectedImage)!
                         
            let featuresInCGIImage = ciDetectorObj.features(in: ciImage)
            
            var qrCodeAddress = ""
                 
            for feature in featuresInCGIImage as! [CIQRCodeFeature] {
                qrCodeAddress += feature.messageString!
            }
            
            if !qrCodeAddress.isEmpty {
                viewModel.parseAnAddress(address: qrCodeAddress)
            }
         
            self.image = nil
            
            viewModel.showInvalidAddressMessage = false

        }
    }
    
    private var torchAvailable: Bool {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false}
        return device.hasTorch
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { logger.info("Torch isn't available"); return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            // Optional thing you may want when the torch it's on, is to manipulate the level of the torch
            if on { try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel) }
            device.unlockForConfiguration()
        } catch {
            logger.info("Torch can't be used")
        }
    }
}
