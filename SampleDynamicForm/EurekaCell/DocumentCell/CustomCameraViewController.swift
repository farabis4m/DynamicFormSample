//
//  CustomCameraViewController.swift
//  Test
//
//  Created by Lincy Francis on 7/4/19.
//  Copyright © 2019 Lincy. All rights reserved.
//

import UIKit
import AVFoundation
import Eureka

class CustomCameraViewController: UIViewController, RowControllerType {
    public var row: DDocumentRow!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var documents: [String: UIImage?]?
    var selectedIndexpath = IndexPath(row: 0, section: 0)
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: CustomCameraViewController.identifier, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?) {
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let document = row.values.first {
           updateTitle(document: document)
        }
        collectionView.register(UINib(nibName: DocumentCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DocumentCollectionViewCell.cellIdentifier)
        documents = [:]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Unable to access back camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        } catch let error {
            print("Error unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame.size = self.previewView.frame.size
            }
        }
    }
    
    func updateTitle(document: Listable) {
         titleLabel.text = document.listName
    }
    
    
    @IBAction func didTapOnTakePhotoButton(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }

    @IBAction func buttonActionDone(_ sender: UIButton) {
        onDismissCallback?(self)
    }

}

extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        let code = row.values[selectedIndexpath.row].code
        if !code.isEmpty {
            documents?.removeValue(forKey: code)
            documents?.updateValue(image, forKey: code)
            collectionView.reloadData()
        }
    }
}

extension CustomCameraViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return row.values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionViewCell.cellIdentifier, for: indexPath) as? DocumentCollectionViewCell else { return UICollectionViewCell() }

        let code = row.values[indexPath.row].code
        if let image = documents?[code] {
            cell.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexpath = indexPath
        let document = row.values[indexPath.row]
        updateTitle(document: document)
    }
}
