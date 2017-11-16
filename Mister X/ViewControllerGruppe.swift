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
    
    
    @IBAction func button_start(_ sender: UIButton) {
        performSegue(withIdentifier: "toNoNav", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        personController.persons = 0
        
        
        let defaults = UserDefaults.standard
        let currentGame = defaults.string(forKey: "currentGame")
        
        //show currentGame code
        gameCode.text = currentGame
        
        //add listener for new players
        var ref: DatabaseReference
        ref = Database.database().reference().child("game").child(currentGame!).child("player")
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            self.personController.persons = self.personController.persons+1
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
