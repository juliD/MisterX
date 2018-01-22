//
//  TabBarController.swift
//  Mister X
//
//  Created by admin on 22.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import UIKit
import Firebase
class TabBarController: UITabBarController {

    var ref: DatabaseReference!
    var currentGame: String = ""
    var userid: String = ""
    
    var nextMisterX = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()

        let defaults = UserDefaults.standard
        currentGame = defaults.string(forKey: "gameCode")!
        userid = defaults.string(forKey: "uid")!
        
        
        ref.child("game").child(currentGame).child("MisterX").observeSingleEvent(of: .childRemoved, with: {(snapshot) in
            
            self.ref.child("game").child(self.currentGame).child("player").child(self.userid).observeSingleEvent(of: .value, with: { (snapshot) in
                defaults.set("", forKey: "activeGame")

                self.nextMisterX = snapshot.childSnapshot(forPath: "MisterX").value! as! Bool
                if(self.nextMisterX){
                    defaults.set("y", forKey: "misterX")
                    let alert = UIAlertController(title: "Spiel beendet!", message: "Du bist der neue Mister-X", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
                        self.performSegue(withIdentifier: "newGameMisterX", sender: self)
                        }))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    defaults.set("", forKey: "misterX")
                    let alert = UIAlertController(title: "Spiel beendet!", message: "Du bist jetzt Jäger", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
                        self.performSegue(withIdentifier: "newGameJaeger", sender: self)
                        }))
                    self.present(alert, animated: true, completion: nil)
                    //not nextMisterX
                    self.performSegue(withIdentifier: "newGameJaeger", sender: self)
                }
                

            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
