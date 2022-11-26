//
//  QRScannerView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 25/06/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

/// Delegate callback for the QRScannerView.
public protocol QRScannerViewDelegate: class {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ str: String?)
    func qrScanningDidStop()
}

extension Notification.Name {
    static let resumeRecordingIfPaused = Notification.Name(rawValue: "resumeRecordingIfPaused")
    static let pauseVideoRecording = Notification.Name(rawValue: "pauseVideoRecording")
}

public class QRScannerView: UIView {
    
    public weak var delegate: QRScannerViewDelegate?
    
    public var continueVideoSessionAfterScanning = false
    /// capture settion which allows us to start and stop scanning.
    var captureSession: AVCaptureSession?
    
    // Init methods..
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitialSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(pauseVideoRecording(notification:)), name: .pauseVideoRecording, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeRecordingIfPaused(notification:)), name: .resumeRecordingIfPaused, object: nil)
    }
    
    @objc func pauseVideoRecording(notification: Notification) {
        if captureSession!.isRunning {
            captureSession!.stopRunning()
        }
    }
    @objc func resumeRecordingIfPaused(notification: Notification) {
        if !captureSession!.isRunning {
            captureSession!.startRunning()
        }
    }
    
    //MARK: overriding the layerClass to return `AVCaptureVideoPreviewLayer`.
    override public class var layerClass: AnyClass  {
        return AVCaptureVideoPreviewLayer.self
    }
    override public var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
}

public extension QRScannerView {
    
    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }
    
    func startScanning() {
       captureSession?.startRunning()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        delegate?.qrScanningDidStop()
    }
    
    /// Does the initial setup for captureSession
    private func doInitialSetup() {
        clipsToBounds = true
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error)
            return
        }
        
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            scanningDidFail()
            return
        }
        
        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
        
    }
    func scanningDidFail() {
        delegate?.qrScanningDidFail()
        captureSession = nil
    }
    
    func found(code: String) {
        delegate?.qrScanningSucceededWithCode(code)
    }
    
}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            if !continueVideoSessionAfterScanning {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            found(code: stringValue)
        }
        if !continueVideoSessionAfterScanning {
            stopScanning()
        }
    }
    
}
