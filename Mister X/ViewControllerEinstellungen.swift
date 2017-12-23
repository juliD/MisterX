//
//  ViewControllerEinstellungen.swift
//  Mister X
//
//  Created by admin on 09.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import Firebase


class ViewControllerEinstellungenTable: UITableViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var foundButton: UIButton!
    @IBOutlet weak var resetPictureButton: UIButton!


    var imagePicker: UIImagePickerController!
    
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    var imageRef: DatabaseReference!
    
    var foundMisterxImage: UIImage!
    var userid = ""
    
    var currentGame = ""
    
    @IBAction func button_newgame(_ sender: UIButton) {
        // create the alert
        let alert = UIAlertController(title: "Achtung", message: "Sicher ein neues Spiel anfangen?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ja!", style: UIAlertActionStyle.destructive, handler: { action in
            let defaults = UserDefaults.standard
            defaults.set("", forKey:"gameCode")
            defaults.set("", forKey:"currentGame")
            defaults.set("", forKey:"misterX")
            self.performSegue(withIdentifier: "newgame", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        resetPictureButton.isHidden = true
        resetPictureButton.isEnabled = false
        
        let defaults = UserDefaults.standard
        currentGame = defaults.string(forKey: "currentGame")!
        userid = defaults.string(forKey: "uid")!
        if (currentGame.isEmpty == true){
            currentGame = defaults.string(forKey: "gameCode")!
        }
        let misterx = defaults.string(forKey:"misterX")!
        //change button depending if you are mister x or not
        if(misterx=="y"){
            foundButton.isHidden = true
            foundButton.isEnabled = false
            resetPictureButton.isHidden = false
            resetPictureButton.isEnabled = true
            
        }
        
        storageRef = Storage.storage().reference(forURL: "gs://misterx-a31d5.appspot.com/")
        ref = Database.database().reference()
        imageRef = ref.child("game").child(currentGame).child("images")
        
        //register tap on imageview
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ViewControllerEinstellungenTable.imageTapped))
        imageView.addGestureRecognizer(singleTap)
        
        //load the picture whenever it is ready to download
        ref.child("game").child(currentGame).observe(.childAdded, with: {(snapshot) -> Void in
            self.ref.child("game").child(self.currentGame).child("images").observeSingleEvent(of: .value, with: { (snapshot) in                
                // check if user has uploaded a photo
                if snapshot.hasChild("startPhoto"){
                    // set image location
                    let filePath = "\(self.currentGame)/\("startPhoto")"
                    // Assuming a < 15MB file, though you can change that
                    self.storageRef.child(filePath).getData(maxSize: 15*1024*1024, completion: { (data, error) in
                        let startPhoto = UIImage(data: data!)
                        self.imageView.image = startPhoto
                    })
                }
            })
        })
        
        
       
        
    }
    
    //when image is tapped make it fullscreen and disable fullscreen by tapping again
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //dismiss fullscreen image
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func found_misterx(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func reset_picture(_ sender: UIButton) {
        // create the alert
        let alert = UIAlertController(title: "Wirklich zurücksetzen?", message: "Sicher, dass nicht du der Mister X auf dem Bild im Chat bist?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.destructive, handler: { action in
            self.imageRef.child("foundPhoto").setValue("")
            // Create a reference to the file to delete
            let filePath = "\(self.currentGame)/\("foundPhoto")"
            
            let deleteref = self.storageRef.child(filePath)
            
            // Delete the file
            deleteref.delete { error in
                if let error = error {
                    print("Error: Unable to delete picture,\(error)")
                } else {
                    print("Picture reseted successfully!")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //take photo from image picker and upload it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            foundMisterxImage = image
            dismiss(animated: true, completion: nil)
        }
        
        var data = NSData()
        data = UIImageJPEGRepresentation(imageView.image!, 0.3)! as NSData
        // set upload path
        let filePath = "\(currentGame)/\("foundPhoto")"
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
                self.imageRef.child("foundPhoto").setValue(downloadURL)
            }
        }
    }

    
    
    
    
}

class ViewControllerEinstellungen: UIViewController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
