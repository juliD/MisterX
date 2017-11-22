//
//  ViewControllerAddPhoto.swift
//  Mister X
//
//  Created by admin on 22.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import Firebase

class ViewControllerAddPhoto: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
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
        ref.child("game/\(currentGame!)/startetAt").setValue(time)
        performSegue(withIdentifier: "toNoNav", sender: self)
        
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
