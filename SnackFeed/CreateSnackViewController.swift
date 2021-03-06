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
    
    var snackImage: UIImage?
    
    let resetImageButton: Button = {
        let button = Button()
        button.defaultBackgroundColor = .clear
        button.highlightColor = .lightGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 35
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 4
        button.alpha = 0.1
        return button
    }()
    
    lazy var previewHeight: CGFloat = self.view.frame.size.height * 0.4
    lazy var snackImageCropView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.previewHeight))
        view.clipsToBounds = true
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    lazy var previousCenterY: CGFloat = self.previewHeight / 2
    
    lazy var snackImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        imageView.center = CGPoint(x: self.view.center.x, y: self.previousCenterY)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var previewView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        view.center = CGPoint(x: self.view.center.x, y: self.previousCenterY)
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    let cameraButton: Button = {
        let button = Button()
        button.defaultBackgroundColor = .clear
        button.highlightColor = .lightGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 50
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 4
        
        let circle = UIView(frame: CGRect(x: 7, y: 7, width: 86, height: 86))
        circle.backgroundColor = UIColor.lightGray.lighter
        circle.layer.cornerRadius = 43
        circle.clipsToBounds = true
        circle.isUserInteractionEnabled = false
        button.addSubview(circle)
        
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.backgroundColor = UIColor.lightGray.cgColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 35
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 4
        button.alpha = 0
        return button
    }()
    
    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x:35, y: self.previewHeight + 20, width: self.view.frame.size.width, height: 20)
        label.text = "Food Type"
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.alpha = 0.1
        return label
    }()
    var selectedTypeItem: IndexPath? = nil
    var selectedType: String? = nil
    let types = ["Donut", "Bagel", "Pizza", "Fruit", "Vegetables", "Cake", "Cookies"]
    lazy var typeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 0)
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        let frame = CGRect(x:0, y: self.previewHeight + 40, width: self.view.frame.size.width, height: 80)
        
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "type")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        collectionView.alpha = 0.1
        return collectionView
    }()
    
    lazy var allergenLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x:35, y: self.previewHeight + 120, width: self.view.frame.size.width, height: 20)
        label.text = "Allergens"
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.alpha = 0.1
        return label
    }()
    var selectedAllergenItem: IndexPath? = nil
    var selectedAllergen: String? = nil
    let allergens = ["Milk", "Eggs", "Peanuts", "Soy", "Wheat", "Sugar", "Shellfish"]
    lazy var allergenCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 0)
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        let collectionView = UICollectionView(frame: CGRect(x:0, y: self.previewHeight + 140, width: self.view.frame.size.width, height: 80), collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "allergen")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        collectionView.alpha = 0.1
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(snackImageCropView)
        snackImageCropView.addSubview(snackImageView)
        
        view.addSubview(resetImageButton)
        resetImageButton.frame = CGRect(
            x: 20,
            y: view.frame.size.height - 90,
            width: 70,
            height: 70
        )
        resetImageButton.addTarget(self, action: #selector(prepareCameraPreview), for: .touchUpInside)
        
        snackImageCropView.addSubview(previewView)
        prepareCameraPreview()
        
        view.addSubview(typeLabel)
        view.addSubview(typeCollectionView)
        view.addSubview(allergenLabel)
        view.addSubview(allergenCollectionView)
        view.addSubview(shareButton)
        view.addSubview(cameraButton)
        
        cameraButton.frame = CGRect(
            x: view.frame.size.width/2 - 50,
            y: view.frame.size.height - 120,
            width: 100,
            height: 100
        )
        cameraButton.addTarget(self, action: #selector(takePhoto(_:)), for: .touchUpInside)
        
        shareButton.frame = CGRect(
            x: view.frame.size.width - 90,
            y: previewHeight - 35,
            width: 70,
            height: 70
        )
        shareButton.addTarget(self, action: #selector(sharePhoto), for: .touchUpInside)
        
        let imagePanGesture = UIPanGestureRecognizer(target: self, action: #selector(imageDidPanGesture(recognizer:)))
        snackImageView.addGestureRecognizer(imagePanGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func imageDidPanGesture(recognizer: UIPanGestureRecognizer) {
        let maxOffset = ((snackImageView.frame.size.height - previewHeight) / 2) + (previewHeight/2)
        let minOffset = -((snackImageView.frame.size.height - previewHeight) / 2) + (previewHeight/2)
        
        var newCenterY = previousCenterY + recognizer.translation(in: snackImageView).y
        newCenterY = max(min(newCenterY, maxOffset), minOffset)
        
        switch recognizer.state {
        case .began: ()
        case .changed:
            var oldCenter = snackImageView.center
            oldCenter.y = newCenterY
            snackImageView.center = oldCenter
        case .ended:
            previousCenterY = newCenterY
            if let image = snackImageView.image {
                snackImage = cropped(image: image)
            }
        default: ()
        }
    }
    
    func cropped(image: UIImage) -> UIImage? {
        let ratio = previewHeight / view.frame.size.width
        let offsetPercentage = -snackImageView.frame.origin.y / snackImageView.frame.size.height
        let newHeight = image.size.width * ratio
        let offsetY = image.size.height * offsetPercentage
        let cropRect = CGRect(x: offsetY, y: 0, width: newHeight, height: image.size.width)
        
        if let cgImage = image.cgImage, let cropped = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: cropped, scale: 0, orientation: image.imageOrientation)
        }

        return nil
    }
    
    @objc func sharePhoto() {
        guard let image = snackImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        prepareCameraPreview()
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
            
            typeCollectionView.isUserInteractionEnabled = false
            allergenCollectionView.isUserInteractionEnabled = false
            shareButton.isHidden = true
            cameraButton.isHidden = false
            
            UIView.animate(withDuration: 0.2) {
                self.typeCollectionView.alpha = 0.1
                self.typeLabel.alpha = 0.1
                self.allergenCollectionView.alpha = 0.1
                self.allergenLabel.alpha = 0.1
                self.resetImageButton.alpha = 0.1
                self.shareButton.alpha = 0
            }
            
        }
        else if let captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .back) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
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
        
        previousCenterY = (previewHeight/2)
        snackImageView.center = CGPoint(x: self.view.center.x, y: previousCenterY)
    }
    
    func processImage(_ imageData: Data) {
        
        cameraButton.isHidden = true
        shareButton.isHidden = false
        typeCollectionView.isUserInteractionEnabled = true
        allergenCollectionView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.2) {
            self.typeCollectionView.alpha = 1
            self.typeLabel.alpha = 1
            self.allergenCollectionView.alpha = 1
            self.allergenLabel.alpha = 1
            self.shareButton.alpha = 1
            self.resetImageButton.alpha = 1
        }
        
        captureSession.stopRunning()
        previewView.isHidden = true
        
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            
            // Adjust imageView frame to match the actual image
            // dimensions for more accurate cropping
            let imageRatio = image.size.height / image.size.width
            var frame = snackImageView.frame
            frame.size.height = frame.size.width * imageRatio
            snackImageView.frame = frame
            
            snackImageView.image = image
            snackImage = cropped(image: image)
        }
    }
}

extension CreateSnackViewController : AVCapturePhotoCaptureDelegate {
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

extension CreateSnackViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == typeCollectionView {
            selectedTypeItem = indexPath
            selectedType = types[indexPath.row]
            typeLabel.text = selectedType
        } else {
            selectedAllergenItem = indexPath
            selectedAllergen = allergens[indexPath.row]
            allergenLabel.text = selectedAllergen
        }
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == typeCollectionView ? types.count : allergens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == typeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "type", for: indexPath)
            let circle = UIView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
            circle.backgroundColor = .lightGray
            circle.layer.cornerRadius = 30
            circle.clipsToBounds = true
            cell.addSubview(circle)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allergen", for: indexPath)
            let circle = UIView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
            circle.backgroundColor = .lightGray
            circle.layer.cornerRadius = 30
            circle.clipsToBounds = true
            cell.addSubview(circle)
            return cell
        }
    }
}
