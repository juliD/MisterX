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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillPersonController()
        
        let defaults = UserDefaults.standard
        isMisterX = defaults.string(forKey: "misterX")!
        currentGame = defaults.string(forKey: "currentGame")!
        
        if(isMisterX == "y"){
            misterxStatus.text = "Du bist der nächste Mister X! Viel Spaß!"
        }else{
            misterxStatus.text = "Du bist das nächste mal ein Jäger. Schanpp dir Mister X!"
        }

        //add listener for new players
        ref = Database.database().reference()
        
        //listen if a player leaves the group
        ref.child("game").child(currentGame).child("player").observeSingleEvent(of: .childRemoved, with: {(snapshot) in
            
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
    
    @IBAction func startButton(_ sender: Any) {
        
        if(isMisterX == "y"){
            self.performSegue(withIdentifier: "newGameFromLobbyMisterX", sender: self)
        }else{
            self.performSegue(withIdentifier: "newGameFromLobbyJaeger", sender: self)
        }
    }
    @IBAction func leaveButton(_ sender: Any) {
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
    }
    
    func fillPersonController(){
        _ = ref.child("game").child(currentGame).child("player").observe(.value, with: { (snapshot) in
            for _ in snapshot.children {
                self.personController.persons = self.personController.persons + 1
            }
        })
    }

}
