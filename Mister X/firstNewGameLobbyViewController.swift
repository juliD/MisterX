//
//  LobbyViewController.swift
//  Mister X
//
//  Created by admin on 22.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import UIKit
import Firebase

class firstNewGameLobbyViewController: UIViewController {
    
    
    @IBOutlet weak var misterxStatus: UILabel!
    @IBOutlet weak var personController: PersonController!
    @IBOutlet weak var startButton: UIButton!
    
    var ref: DatabaseReference!
    var currentGame: String = ""    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let defaults = UserDefaults.standard
        currentGame = defaults.string(forKey: "gameCode")!
        
        misterxStatus.text = "Du bist ein Jäger. \n warte bis Mister X das Spiel startet."
        startButton.isEnabled = false
        
        
        //add listener for new players
        ref = Database.database().reference()
        
        fillPersonController()
        ref.child("game").child(currentGame).observe(.childAdded, with: {(snapshot) -> Void in
            if snapshot.key == "startetAt"{
                self.performSegue(withIdentifier: "firstNewGameFromLobbyJaeger", sender: self)
            }
        })
        
        
        //listen if a player leaves the group
        ref.child("game").child(currentGame).child("player").observe(.childRemoved, with: {(snapshot) in
            
            self.personController.persons = self.personController.persons-1
            
            
            //muss erhöht werden zum schluss
            //Todo: set it to 2
            if(self.personController.persons<1){
                // create the alert
                let alert = UIAlertController(title: "Jemand ist gegangen", message: "Leider hat jemand das Spiel verlassen. Ihr seid nicht mehr genug Teilnehmer, um ein Spiel zu starten.", preferredStyle: UIAlertControllerStyle.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                    self.ref.child("game").child(self.currentGame).removeValue()
                    let defaults = UserDefaults.standard
                    defaults.set("", forKey: "activeGame")
                    defaults.set(0, forKey:"boost1")
                    defaults.set(0, forKey:"boost2")
                    defaults.set("", forKey:"gameCode")
                    defaults.set("", forKey:"misterX")
                    self.performSegue(withIdentifier: "leaveGame", sender: self)
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            
        })
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fillPersonController(){
        _ = ref.child("game").child(currentGame).child("player").observe(.value, with: { (snapshot) in
            self.personController.persons = 0
            for user in snapshot.children {
                //count up for each participant
                self.personController.persons = self.personController.persons + 1
            }
        })
    }
    
    
    
}

