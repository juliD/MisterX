//
//  ViewControllerEinstellungen.swift
//  Mister X
//
//  Created by admin on 09.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import Firebase


class ViewControllerEinstellungenTable: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    var imageRef: DatabaseReference!
    
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
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ViewControllerEinstellungenTable.imageTapped))
        imageView.addGestureRecognizer(singleTap)
        
        let defaults = UserDefaults.standard
        currentGame = defaults.string(forKey: "currentGame")!
        
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
                    })
                }
            })
        })
        
        
       
        
    }
    
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
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
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
