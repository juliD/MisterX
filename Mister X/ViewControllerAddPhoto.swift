//
//  ViewControllerAddPhoto.swift
//  Mister X
//
//  Created by admin on 22.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import Firebase

class ViewControllerAddPhoto: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    var imagePicker: UIImagePickerController!
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    var imageRef: DatabaseReference!
    
    var currentGame: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        //getting information about the user
        let defaults = UserDefaults.standard
        currentGame = defaults.string(forKey: "gameCode")!

        storageRef = Storage.storage().reference(forURL: "gs://misterx-a31d5.appspot.com/")
        ref = Database.database().reference()
        imageRef = ref.child("game").child(currentGame).child("images")

        startButton.isHidden = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ViewControllerAddPhoto.tapDetected))
        imageView.addGestureRecognizer(singleTap)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        startCamera()
    }
    

    //use image and set it as a preview
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            
           
            photoButton.isHidden = true
            startButton.isHidden = false
            dismiss(animated: true, completion: nil)
        
        
            
        }
    
    }
    
    //optionally implemented because apple advises to do it
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func tapDetected() {
        startCamera()
    }
    
    //shows camera
    func startCamera(){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    

    
    //go to main navigation screen
    @IBAction func button_start(_ sender: UIButton) {
        var data = NSData()
        data = UIImageJPEGRepresentation(imageView.image!, 0.3)! as NSData
        // set upload path
        let filePath = "\(currentGame)/\("startPhoto")"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        self.storageRef.child(filePath).putData(data as Data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                //store downloadURL at database
                self.imageRef.child("startPhoto").setValue(downloadURL)
            }
            
        }
        
        performSegue(withIdentifier: "toNoNav", sender: self)
    }
        

    

}
