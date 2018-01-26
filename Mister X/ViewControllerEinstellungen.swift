//
//  ViewControllerEinstellungen.swift
//  Mister X
//
//  Created by admin on 09.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import Firebase


class ViewControllerEinstellungen: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var foundPicture: UIImageView!
    @IBOutlet weak var foundButton: UIButton!
    @IBOutlet weak var resetPictureButton: UIButton!
    @IBOutlet weak var nextMisteXButton: UIButton!

    @IBOutlet weak var finderName: UILabel!
    @IBOutlet weak var misterXName: UILabel!


    
    
    var imagePicker: UIImagePickerController!
    
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    var imageRef: DatabaseReference!
    
    var userid = ""
    
    var currentGame = ""
    var foundPhotoPosted = false
    var participants = [String]()

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        misterXName.text = "Lädt..."
        finderName.text = "Offen"
        
        

        
        let defaults = UserDefaults.standard
        currentGame = defaults.string(forKey: "gameCode")!
        userid = defaults.string(forKey: "uid")!
        let misterx = defaults.string(forKey:"misterX")!
        
        
         resetPictureButton.isHidden = true
         resetPictureButton.isEnabled = false
         nextMisteXButton.isHidden = true
         nextMisteXButton.isEnabled = false
        //change button depending if you are mister x or not
        if(misterx=="y"){
            foundButton.isHidden = true
            foundButton.isEnabled = false
            resetPictureButton.isHidden = false
            resetPictureButton.isEnabled = true
            nextMisteXButton.isHidden = false
            nextMisteXButton.isEnabled = true
            
        }
 
        
        storageRef = Storage.storage().reference(forURL: "gs://misterx-a31d5.appspot.com/")
        ref = Database.database().reference()
        imageRef = ref.child("game").child(currentGame).child("images")
        
        
        
        
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
                        //register tap on imageview
                        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewControllerEinstellungen.misterxImageTapped(_:))))
                    })
                }
            })
        })
        
        //load username of misterX
        getMisterxName()
        
        //listen if picture gets removed
        listenForPictureRemoved()
        
        //load the foundPicture whenever it is ready to download
        ref.child("game").child(currentGame).child("images").observe(.childAdded, with: {(snapshot) -> Void in

            self.ref.child("game").child(self.currentGame).child("images").child("foundPhoto").observeSingleEvent(of: .value, with: { (snapshot) in
                // check if user has uploaded a photo
                if snapshot.hasChild("url"){
                    // set image location
                    let filePath = "\(self.currentGame)/\("foundPhoto")"
                    // Assuming a < 15MB file, though you can change that
                    self.storageRef.child(filePath).getData(maxSize: 15*1024*1024, completion: { (data, error) in
                        let foundPhoto = UIImage(data: data!)
                        self.foundPicture.image = foundPhoto
                        self.foundPicture.isHidden = false
                        self.foundPicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewControllerEinstellungen.foundPictureTapped(_:))))
                        
                        self.foundPhotoPosted = true
                    })
                }
                if snapshot.hasChild("finderID"){
                    //finderID exist we make a call for get username and refresh the label when the result is there
                    let finderID = snapshot.childSnapshot(forPath: "finderID").value!
                    self.getUsername(userid: finderID as! String){
                        (result : String) in
                        self.finderName.text = result
                    }
                    

                }
            })
            
            
        })
        
    }
    
    //when image is tapped make it fullscreen and disable fullscreen by tapping again
    @IBAction func misterxImageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.isUserInteractionEnabled = true
        //show the image properly and do not let it be streched
        if(newImageView.image?.size.height.isLess(than: (newImageView.image?.size.width)!))!{
            newImageView.contentMode = .scaleAspectFit
        }
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
    
    //present camera
    @IBAction func found_misterx(_ sender: UIButton) {
        if(!foundPhotoPosted){
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self as UIImagePickerControllerDelegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }else{
            // create the alert
            let alert = UIAlertController(title: "Mister-X muss zurücksetzen", message: "Du kannst nicht ein neues Foto hochladen, solange Mister-X nicht das Foto zurückgesetzt hat.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func reset_picture(_ sender: UIButton) {
        
        if(foundPhotoPosted){
            // create the alert
            let alert = UIAlertController(title: "Wirklich zurücksetzen?", message: "Sicher, dass nicht du der Mister X auf dem Bild im Chat bist?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.destructive, handler: { action in
                self.imageRef.child("foundPhoto").removeValue()
                // Create a reference to the file to delete
                let filePath = "\(self.currentGame)/\("foundPhoto")"
                self.foundPicture.isHidden = true
                self.finderName.text = "Offen"
                self.foundPhotoPosted = false
                
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
        }else{
            // create the alert
            let alert = UIAlertController(title: "Nicht zurücksetzbar", message: "Es wurde noch kein Foto gepostet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    //take photo from image picker and upload it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            foundPicture.image = image
            dismiss(animated: true, completion: nil)
        }
        
        var data = NSData()
        data = UIImageJPEGRepresentation(foundPicture.image!, 0.3)! as NSData
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
                self.imageRef.child("foundPhoto").child("url").setValue(downloadURL)
                self.imageRef.child("foundPhoto").child("finderID").setValue(self.userid)
                
                //post
                let singleMessageRef = self.ref.child("game").child(self.currentGame).child("messages").childByAutoId()
                let foundMessage = "Ich habe Mister-X gefunden! Mister-X schau dir mein Bild an und lösche es, falls du es nicht bist!"
                let message = ["sender_id": self.userid, "text": foundMessage]
                singleMessageRef.setValue(message)
            }
        }
    }
    
    //querries for the misterx in the current game, looks up his name in the database and displays his name in the textfield
    func getMisterxName(){
        _ = ref.child("game").child(currentGame).child("player").queryOrdered(byChild: "MisterX").queryEqual(toValue: true).observe(.value, with: { (snapshot) in
            
            for snap in snapshot.children {
                let userid = (snap as! DataSnapshot).key
                self.getUsername(userid: userid ){
                    (result : String) in
                    self.misterXName.text = result
                }
            }
        })
    }
    
    //function with completion handler. When the data is fetched the result will be given without blocking the rest
    func getUsername(userid: String, completion: @escaping (_ result: String) -> Void){
        let usernameref = ref.child("user").child(userid).child("username")
        usernameref.observe(.value, with: { (snapshot) in
            //get the single value
            if let value = snapshot.value as? String{
                completion(value)
            }
        })
    }
    
    @IBAction func button_newgame(_ sender: UIButton) {
        
        // create the alert
        let alert = UIAlertController(title: "Achtung", message: "Spiel beenden oder eine neue Runde mit den gleichen Mitspielern beginnen?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Neue Runde", style: UIAlertActionStyle.default, handler: { action in
            self.performSegue(withIdentifier: "toPicker", sender: self)
        }))
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Spiel beenden", style: UIAlertActionStyle.destructive, handler: { action in
            
            let alert = UIAlertController(title: "Achtung", message: "Wirklich das Spiel beenden und die Lobby auflösen?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.destructive, handler: { action in
                let defaults = UserDefaults.standard
                defaults.set("", forKey:"gameCode")
                defaults.set("", forKey:"misterX")
                defaults.set("", forKey:"activeGame")
                self.ref.child("game").child(self.currentGame).child("gameClosed").setValue(true)
                self.performSegue(withIdentifier: "endGame", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
 
    }
    
    //has to be defined a second time because apple only wants one gesture for one thing
    @IBAction func foundPictureTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        if(newImageView.image?.size.height.isLess(than: (newImageView.image?.size.width)!))!{
            newImageView.contentMode = .scaleAspectFit
        }
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    func listenForPictureRemoved(){
        //listen if the pictures is removed
        ref.child("game").child(currentGame).child("images").observeSingleEvent(of: .childRemoved, with: {(snapshot) in
            self.foundPicture.isHidden = true
            self.finderName.text = "Offen"
            self.foundPhotoPosted = false            
        })
    }
    
}
