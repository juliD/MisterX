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
            displayTutorial()
            logInOnce()
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
            
            //>>>>>>>>>>>>>>Needs to be replaced sometime in the future with real name in settings
            defaults.set("Horst Schlämmer", forKey:"name")

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
        defaults.set(key, forKey: "currentGame")
        defaults.set("y", forKey: "misterX")
    }
    
    func displayTutorial(){
        //if the storyboard for the Page View Controller exist show it to the user
        if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "TutorialPageViewController"){
            self.present(pageViewController, animated: true, completion: nil)
        }
    }
    

}

