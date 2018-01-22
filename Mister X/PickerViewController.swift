//
//  PickerViewController.swift
//  Mister X
//
//  Created by admin on 20.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import UIKit
import Firebase

class PickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak internal var pickerview: UIPickerView!
    @IBOutlet weak var nextPersonLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var pickerData: [String] = [String]()
    var ref: DatabaseReference!
    var storageRef: StorageReference!

    var currentGame: String = ""
    var participants:[(id: String, name: String)] = []
    var userid: String = ""
    var nextMisterXid: String = ""

    

    
    override func viewDidLoad() {
        super.viewDidLoad()        
                
        let defaults = UserDefaults.standard
        currentGame = defaults.string(forKey: "gameCode")!
        userid = defaults.string(forKey: "uid")!

        ref = Database.database().reference()
        storageRef = Storage.storage().reference(forURL: "gs://misterx-a31d5.appspot.com/")

        getParticipantsNames()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The number of columns of data

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return participants.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return participants[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nextPersonLabel.numberOfLines = 0
        nextPersonLabel.text = "Nächster Mister-X:\n\(participants[row].name)"
        nextMisterXid = participants[row].id
    }
    
    @IBAction func resetGame(_ sender: UIButton) {
        
        if(nextMisterXid.isEmpty){
            // create the alert
            let alert = UIAlertController(title: "Achtung", message: "Du hast noch niemanden als Nachfolger ausgewählt", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
        if(nextMisterXid == userid){
            let alert = UIAlertController(title: "Spielverderber!", message: "Wähle die Person, die dich gefunden hat! Wenn dich niemand gefunden hat, gib den anderen trotzdem die Chance Mister-X zu sein.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        // create the alert
        let alert = UIAlertController(title: "Achtung", message: "Sicher ein neues Spiel mit diesem Mister-X anfangen?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.destructive, handler: { action in
            self.deleteFiles()

            let defaults = UserDefaults.standard
            defaults.set("", forKey: "activeGame")

            //set next mister x
            if(self.userid != self.nextMisterXid){
                //set yourself to not be misterx anymore
                defaults.set("", forKey:"misterX")
                self.ref.child("game").child(self.currentGame).child("player").child(self.userid).child("MisterX").setValue(false)
                //set other person as misterx
                self.ref.child("game").child(self.currentGame).child("player").child(self.nextMisterXid).child("MisterX").setValue(true)
                
            }
            self.performSegue(withIdentifier: "newgame", sender: self)
            }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func getParticipantsNames(){
        _ = ref.child("game").child(currentGame).child("player").observe(.value, with: { (snapshot) in
            for snap in snapshot.children {
                let userid = (snap as! DataSnapshot).key                
                self.getUsername(userid: userid ){
                    (result : String) in
                    self.participants.append((id: userid, name: result))
                    self.pickerview.delegate = self

                }
            }
        })
    }
    
    //function with completion handler. When the data is fetched the result will be given without blocking the rest
    func getUsername(userid: String, completion: @escaping (_ result: String) -> Void){
        let usernameref = ref.child("user").child(userid).child("username")
        usernameref.observe(.value, with: { (snapshot) in
            //get the single value
            if let value = snapshot.value as? String{
                completion(value)
            }
        })
    }
    
    func deleteFiles(){
        self.ref.child("game").child(self.currentGame).child("messages").removeValue()
        self.ref.child("game").child(self.currentGame).child("MisterX").removeValue()
        self.ref.child("game").child(self.currentGame).child("Jaeger").removeValue()
        self.ref.child("game").child(self.currentGame).child("startetAt").removeValue()
        self.ref.child("game").child(self.currentGame).child("images").removeValue()
        // Create a reference to the file to delete
        let filePathFound = "\(self.currentGame)/\("foundPhoto")"
        let filePathStart = "\(self.currentGame)/\("startPhoto")"
        
        let deleterefFound = self.storageRef.child(filePathFound)
        
        // Delete the file
        deleterefFound.delete { error in
            if let error = error {
                print("Error: Unable to delete picture,\(error)")
            } else {
                print("Picture reseted successfully!")
            }
        }
        let deleterefStart = self.storageRef.child(filePathStart)
        // Delete the file
        deleterefStart.delete { error in
            if let error = error {
                print("Error: Unable to delete picture,\(error)")
            } else {
                print("Picture reseted successfully!")
            }
        }
    }

}
