//
//  ScannerViewController.swift
//  Mister X
//
//  Created by admin on 16.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import AVFoundation
import UIKit
import FirebaseDatabase

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        
        // Start video capture.
        captureSession?.startRunning()
        
        view.bringSubview(toFront: messageLabel)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if  metadataObjects.count == 0 {
            messageLabel.text = "No QR code is detected"
            return
        }
        
        captureSession?.stopRunning()
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
        
        let defaults = UserDefaults.standard
        var ref: DatabaseReference!
        ref = Database.database().reference().child("game")
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild(metadataObj.stringValue!){
                
                //get userid
                
                let uid = defaults.string(forKey: "uid")
                ref.child(metadataObj.stringValue!).child("player").child(uid!).setValue(["MisterX" : false])
                ref = Database.database().reference().child("game").child(metadataObj.stringValue!)
                ref.observe(.childAdded, with: {(snapshot) -> Void in
                    if snapshot.key == "startetAt"{
                        self.startGame()
                        
                    }
                })
                
            }else{
                print("Wrong QR Code")
            }
        })
        
        defaults.set(metadataObj.stringValue!, forKey:"gameCode")
        defaults.set("", forKey:"misterX")
        performSegue(withIdentifier: "backToGroup", sender: self)
    }
    func startGame(){
        performSegue(withIdentifier: "showTimerFromGroup", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
}
