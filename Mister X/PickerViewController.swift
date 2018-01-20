//
//  PickerViewController.swift
//  Mister X
//
//  Created by admin on 20.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak internal var pickerview: UIPickerView!
    @IBOutlet weak var nextPersonLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    var pickerData: [String] = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()        
        pickerData = ["Florian", "Julia", "Bill", "Tobias", "Felix", "Matthias"]
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
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nextPersonLabel.text = "Nächster Mister-X: \(pickerData[row])"
    }
    
    @IBAction func resetGame(_ sender: UIButton) {
        // create the alert
        let alert = UIAlertController(title: "Achtung", message: "Sicher ein neues Spiel mit diesem Mister-X anfangen?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ja!", style: UIAlertActionStyle.destructive, handler: { action in
            let defaults = UserDefaults.standard
            defaults.set("", forKey:"gameCode")
            defaults.set("", forKey:"misterX")
            self.performSegue(withIdentifier: "newgame", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
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
