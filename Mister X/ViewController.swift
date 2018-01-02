//
//  ViewController.swift
//  Mister X
//
//  Created by admin on 08.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        //if userid does not exist yet sign into firebase
        //always use locally stored uid otherwise we get problems with firebase
        let defaults = UserDefaults.standard
        
        if let uid = defaults.string(forKey: "uid"){
            print("already logged in: "+uid)
        }
        else {
            logInOnce()
            displayTutorial()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     Sign into firebase anonymously, save userid to persist data
     and create a user in firebase
     */
    func logInOnce(){
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            //save data locally
            print("User logged in anonymously with uid: "+user!.uid)
            let defaults = UserDefaults.standard
            defaults.set(user!.uid, forKey:"uid")
            defaults.set(0, forKey:"boost1")
            defaults.set(0, forKey:"boost2")
            defaults.set("", forKey:"gameCode")
            
            //set up firebase user
            let boosts = [
                "username" : "Agent",
                "boost1" : 0,
                "boost2" : 0
                ] as [String : Any]
            self.ref.child("user").child(user!.uid).setValue(boosts)
        })
    }
    
    @IBAction func createNewGame(_ sender: UIButton) {
        //get userid
        let defaults = UserDefaults.standard
        let uid = defaults.string(forKey: "uid")
        
        //create new game in firebase
        let key = self.ref.child("games").childByAutoId().key
        self.ref.child("game").child(key).child("player").child(uid!).setValue(["MisterX" : true])
        
        //save gameid locally
        defaults.set(key, forKey: "gameCode")
        defaults.set("y", forKey: "misterX")
    }
    
    @IBAction func joinGame(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        let currentGame = defaults.string(forKey: "gameCode")
        if (currentGame?.isEmpty)!{
            let alert = UIAlertController(title: "Achtung", message: "Du hast kein laufendes Spiel...", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else{
            
            var ref: DatabaseReference!
            ref = Database.database().reference().child("game")
            
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                if snapshot.hasChild(currentGame!){
                    
                    ref = Database.database().reference().child("game").child(currentGame!)
                    ref.observe(.childAdded, with: {(snapshot) -> Void in
                        if snapshot.key == "startetAt"{
                            self.performSegue(withIdentifier: "runningGame", sender: self)
                        }
                    })
                    
                }else{
                    print("game code doesn't exist")
                    let alert = UIAlertController(title: "Achtung", message: "Dein Spiel wurde gelöscht...", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                }
            
            })
        }
    }
    
    
    func displayTutorial(){
        //if the storyboard for the Page View Controller exist show it to the user
        if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "TutorialPageViewController"){
            self.present(pageViewController, animated: true, completion: nil)
        }
    }
    

}

