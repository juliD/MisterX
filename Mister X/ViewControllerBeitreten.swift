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
    @IBOutlet weak var findQR: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
      
    }

    @IBAction func changeGame(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
        defaults.set("",forKey: "gameCode")
        textField.isUserInteractionEnabled = true
        findQR.isEnabled=true
        
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


    func textFieldDidEndEditing(_ textField: UITextField) {
        //add this user to game if game code is correct
        var ref: DatabaseReference!
        ref = Database.database().reference().child("game")
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild(textField.text!){
                
                //get userid
                let defaults = UserDefaults.standard
                let uid = defaults.string(forKey: "uid")
                let pushToken = defaults.string(forKey: "pushToken")
                
                ref.child(textField.text!).child("player").child(uid!).setValue(["MisterX" : false, "pushToken" : pushToken!])
                textField.isUserInteractionEnabled = false;
                self.textLabel.text = "Warte bis Mister X das Spiel beginnt..."
                
                defaults.set(textField.text, forKey:"gameCode")
                defaults.set("", forKey:"misterX")
                self.performSegue(withIdentifier: "startToLobby", sender: self)
                
            }else{
                print("game code doesn't exist")
                textField.text = "Spiel existiert nicht"
            }
        })
        
        
        
    }

}
