//
//  SnackCamera.swift
//  SnackFeed
//
//  Created by Daniel Burke on 9/10/17.
//  Copyright © 2017 SnackFeed. All rights reserved.
//

import UIKit
import AVFoundation

class SnackCamera: NSObject {
    var captureSession = AVCaptureSession()
    var capturePhotoOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var previewView: UIView
    
    init(previewView: UIView) {
        self.previewView = previewView
        super.init()
    }
    
    func prepareCameraPreview() {
        if videoPreviewLayer != nil {
            captureSession.startRunning()
        }
        else if let captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .back) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
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
            //Call some delegate method to return image
        }
    }
}

extension SnackCamera : AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
                 previewPhotoSampleBuffer: CMSampleBuffer?,
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
