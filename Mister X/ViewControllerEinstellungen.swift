//
//  ViewControllerEinstellungen.swift
//  Mister X
//
//  Created by admin on 09.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit

class ViewControllerEinstellungenTable: UITableViewController {
    @IBAction func button_newgame(_ sender: UIButton) {
        // create the alert
        let alert = UIAlertController(title: "Achtung", message: "Sicher ein neues Spiel anfangen?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ja!", style: UIAlertActionStyle.destructive, handler: { action in
            self.performSegue(withIdentifier: "newgame", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

class ViewControllerEinstellungen: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
