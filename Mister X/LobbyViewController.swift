//
//  LobbyViewController.swift
//  Mister X
//
//  Created by admin on 22.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import UIKit
import Firebase

class LobbyViewController: UIViewController {


    @IBOutlet weak var misterxStatus: UILabel!
    @IBOutlet weak var personController: PersonController!
    @IBOutlet weak var startButton: UIButton!

    var isMisterX: String = ""
    var ref: DatabaseReference!
    var currentGame: String = ""
    var userid: String = ""
    
    var participants: [String] = [String]()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let defaults = UserDefaults.standard
        isMisterX = defaults.string(forKey: "misterX")!
        currentGame = defaults.string(forKey: "gameCode")!
        userid = defaults.string(forKey: "uid")!

    

        if(isMisterX == "y"){
            misterxStatus.text = "Du bist der nächste Mister X! Viel Spaß!"
        }else{
            misterxStatus.text = "Du bist ab jetzt ein Jäger. Schanpp dir Mister X!"
        }

        //add listener for new players
        ref = Database.database().reference()
        
        fillPersonController()
        ref.child("game").child(currentGame).observe(.childAdded, with: {(snapshot) -> Void in
            if snapshot.key == "startetAt"{
                self.performSegue(withIdentifier: "newGameFromLobbyJaeger", sender: self)
            }
        })
        
        listenIfBecameMisterX()
        
        //listen if a player leaves the group
        ref.child("game").child(currentGame).child("player").observeSingleEvent(of: .childRemoved, with: {(snapshot) in
            
            self.participants = self.participants.filter{$0 != snapshot.key}

            self.personController.persons = self.personController.persons-1
            if(self.personController.persons<2){
                // create the alert
                let alert = UIAlertController(title: "Jemand ist gegangen", message: "Leider hat jemand das Spiel verlassen. Ihr seid nicht mehr genug Teilnehmer, um ein Spiel zu starten.", preferredStyle: UIAlertControllerStyle.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                    self.quitGame()
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
    
    
    
    @IBAction func startButton(_ sender: UIButton) {
        
        if(isMisterX == "y"){
            self.performSegue(withIdentifier: "newGameFromLobbyMisterX", sender: self)
        }else{
            // create the alert
            let alert = UIAlertController(title: "Warten", message: "Du musst warten bis Mister X das Spiel beginnt", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func leaveButton(_ sender: UIButton) {
        // create the alert
        let alert = UIAlertController(title: "Wirklich aufhören?", message: "Wenn du aufhörst, können die anderen nicht weiter spielen! Willst du wirklich aufhören?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.destructive, handler: { action in
            self.quitGame()
            self.performSegue(withIdentifier: "leaveGame", sender: self)

        }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }

    func quitGame(){
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "activeGame")
        defaults.set(0, forKey:"boost1")
        defaults.set(0, forKey:"boost2")
        defaults.set("", forKey:"gameCode")
        defaults.set("", forKey:"misterX")
        self.ref.child("game").child(currentGame).child("player").child(userid).removeValue()
        print(self.participants)
        self.participants = self.participants.filter{$0 != userid}
        print(self.participants)
        self.ref.child("game").child(currentGame).child("player").child(participants[0]).child("MisterX").setValue(true)

    }
    
    func fillPersonController(){
        _ = ref.child("game").child(currentGame).child("player").observe(.value, with: { (snapshot) in
            self.personController.persons = 0
            for user in snapshot.children {
                //count up for each participant
                self.personController.persons = self.personController.persons + 1
                self.participants.append((user as! DataSnapshot).key)
            }
        })
    }
    
    func listenIfBecameMisterX(){
        self.ref.child("game").child(self.currentGame).child("player").child(self.userid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let nextMisterX = snapshot.childSnapshot(forPath: "MisterX").value! as! Bool
            
            //check if you are going to become a jaeger or mister-x
            if(nextMisterX){
                let defaults = UserDefaults.standard
                defaults.set("y", forKey: "misterX")
                let alert = UIAlertController(title: "Spiel beendet!", message: "Du bist der neue Mister-X", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    self.misterxStatus.text = "Du bist der nächste Mister X! Viel Spaß!"
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
            
        })
    }

}
