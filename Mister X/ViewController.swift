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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if userid does not exist yet sign into firebase
        //always use locally stored uid otherwise we get problems with firebase
        let defaults = UserDefaults.standard
        if let uid = defaults.string(forKey: "uid"){
            print("already logged in: "+uid)
        }
        else {
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
            
            //set up firebase user
            var ref: DatabaseReference!
            ref = Database.database().reference()
            
            let boosts = [
                "username" : "Agent",
                "boost1" : 0,
                "boost2" : 0
                ] as [String : Any]
            ref.child("user").child(user!.uid).setValue(boosts)
        })

    }

}

