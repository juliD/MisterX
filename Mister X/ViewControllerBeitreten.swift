//
//  ViewControllerBeitreten.swift
//  Mister X
//
//  Created by admin on 16.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewControllerBeitreten: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    func startGame(){
        performSegue(withIdentifier: "startGame", sender: self)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        //add this user to game if game code is correct
        var ref: DatabaseReference!
        ref = Database.database().reference().child("game")
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild(textField.text!){
                
                //get userid
                let defaults = UserDefaults.standard
                let uid = defaults.string(forKey: "uid")
                
                ref.child(textField.text!).child("player").child(uid!).setValue(["MisterX" : false])
                textField.isUserInteractionEnabled = false;
                self.textLabel.text = "Warte bis Mister X das Spiel beginnt..."
                
                ref = Database.database().reference().child("game").child(textField.text!)
                ref.observe(.childAdded, with: {(snapshot) -> Void in
                    if snapshot.key == "startetAt"{
                        self.startGame()
                    }
                })
                
            }else{
                print("game code doesn't exist")
                textField.text = "Spiel existiert nicht"
            }
        })
        
        
        
    }

}
