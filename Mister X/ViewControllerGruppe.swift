//
//  ViewControllerGruppe.swift
//  
//
//  Created by admin on 09.11.17.
//

import UIKit
import FirebaseDatabase

class ViewControllerGruppe: UIViewController {

    @IBOutlet weak var personController: PersonController!
    @IBOutlet weak var gameCode: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    
    @IBAction func button_start(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        let currentGame = defaults.string(forKey: "currentGame")
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let time = "\(hour):\(minutes)"
        var ref: DatabaseReference
        ref = Database.database().reference()
        ref.child("game").child(currentGame!).setValue(["startetAt" : time])
        
        
        performSegue(withIdentifier: "toNoNav", sender: self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        personController.persons = 0
        startButton.isEnabled = false
        
        let defaults = UserDefaults.standard
        let currentGame = defaults.string(forKey: "currentGame")
        
        //show currentGame code
        gameCode.text = currentGame
        
        //add listener for new players
        var ref: DatabaseReference
        ref = Database.database().reference().child("game").child(currentGame!).child("player")
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            self.personController.persons = self.personController.persons+1
            if self.personController.persons == 2 {
                self.startButton.isEnabled = true
            }
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
