//
//  CreateSnackViewController.swift
//  SnackFeed
//
//  Created by Daniel Burke on 9/10/17.
//  Copyright © 2017 SnackFeed. All rights reserved.
//

import UIKit
import AVFoundation

class CreateSnackViewController: UIViewController {
    var captureSession = AVCaptureSession()
    var capturePhotoOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let snackImageButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    var snackImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 375, height: 300))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        return imageView
    }()
    
    var previewView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 300))
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    let cameraButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.layer.cornerRadius = 35
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 4
        
        let circle = UIView(frame: CGRect(x: 7, y: 7, width: 56, height: 56))
        circle.backgroundColor = .lightGray
        circle.layer.cornerRadius = 28
        circle.clipsToBounds = true
        circle.isUserInteractionEnabled = false
        button.addSubview(circle)
        
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .lightGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 35
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 4
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(snackImageView)
        view.addSubview(snackImageButton)
        snackImageButton.frame = snackImageView.frame
        snackImageButton.addTarget(self, action: #selector(prepareCameraPreview), for: .touchUpInside)
        
        view.addSubview(previewView)
        prepareCameraPreview()
        
        view.addSubview(shareButton)
        
        view.addSubview(cameraButton)
        cameraButton.frame = CGRect(
            x: view.frame.size.width/2 - 30,
            y: view.frame.size.height - 90,
            width: 70,
            height: 70
        )
        cameraButton.addTarget(self, action: #selector(takePhoto(_:)), for: .touchUpInside)
        
        shareButton.frame = CGRect(
            x: view.frame.size.width - 90,
            y: 300 - 35,
            width: 70,
            height: 70
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func takePhoto(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        // Call capturePhoto method by passing our photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc func prepareCameraPreview() {
        if videoPreviewLayer != nil {
            captureSession.startRunning()
            previewView.isHidden = false
        }
        else if let captureDevice = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer?.frame = previewView.layer.bounds
                previewView.layer.addSublayer(videoPreviewLayer!)
                
                captureSession.startRunning()
                
                // Get an instance of ACCapturePhotoOutput class
                capturePhotoOutput = AVCapturePhotoOutput()
                if let output = capturePhotoOutput {
                    output.isHighResolutionCaptureEnabled = true
                    // Set the output on the capture session
                    captureSession.addOutput(output)
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func processImage(_ imageData: Data) {
        captureSession.stopRunning()
        previewView.isHidden = true
        
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            snackImageView.image = image
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}

extension CreateSnackViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        
        // Make sure we get some photo sample buffer
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
            forJPEGSampleBuffer: photoSampleBuffer,
            previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                print("Could not save image data")
                return
        }
        
        processImage(imageData)
    }
}
