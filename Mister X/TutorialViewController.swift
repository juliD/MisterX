//
//  TutorialViewController.swift
//  Mister X
//
//  Created by admin on 19.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import Firebase

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!

    
    var index = 0           //for keeping track where you are inside the tutorial
    var headerText = ""
    var descriptionText = ""
    var inputNameField: UITextField = UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
    
    var ref: DatabaseReference!

    let defaults = UserDefaults.standard


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        ref = Database.database().reference()
        

        headerLabel.text = headerText
        descriptionLabel.text = descriptionText
        pageControl.currentPage = index

        //hides or shows the next and start button depending on which page is displayed
        if(index == 3){
            startButton.isHidden = false
            nextButton.isHidden = true
            inputNameField.font = UIFont.systemFont(ofSize: 18)
            inputNameField.borderStyle = UITextBorderStyle.roundedRect
            inputNameField.autocorrectionType = UITextAutocorrectionType.no
            inputNameField.keyboardType = UIKeyboardType.default
            inputNameField.returnKeyType = UIReturnKeyType.done
            inputNameField.clearButtonMode = UITextFieldViewMode.whileEditing;
            inputNameField.placeholder = "Name"
            inputNameField.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(inputNameField)
            
            let constraintTop = NSLayoutConstraint(item: inputNameField,
                                                   attribute: NSLayoutAttribute.top,
                                                   relatedBy: NSLayoutRelation.equal,
                                                   toItem: headerLabel,
                                                   attribute: NSLayoutAttribute.bottom,
                                                   multiplier: 1.0,
                                                   constant: 56)
            let constraintLeft = NSLayoutConstraint(item: inputNameField,
                                                   attribute: NSLayoutAttribute.leading,
                                                   relatedBy: NSLayoutRelation.equal,
                                                   toItem: view,
                                                   attribute: NSLayoutAttribute.leading,
                                                   multiplier: 1.0,
                                                   constant: 24)
            let constraintRight = NSLayoutConstraint(item: inputNameField,
                                                    attribute: NSLayoutAttribute.trailing,
                                                    relatedBy: NSLayoutRelation.equal,
                                                    toItem: view,
                                                    attribute: NSLayoutAttribute.trailing,
                                                    multiplier: 1.0,
                                                    constant: -24)
            self.view.addConstraints([constraintTop,constraintLeft,constraintRight])

        }else{
            startButton.isHidden = true
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startClicked(sender: AnyObject){
        if((inputNameField.text?.isEmpty)!){
            // create the alert
            let alert = UIAlertController(title: "Name eingeben", message: "Um fortzufahren bitte Name eingeben.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else{
            //set name in defaults
            defaults.set(inputNameField.text, forKey:"name")
            self.ref.child("user").child(defaults.string(forKey: "uid")!).child("username").setValue(inputNameField.text)


            self.dismiss(animated: true, completion: nil)       //when start is clicked dismiss current view

        }

    }
    
    @IBAction func nextClicked(sender: AnyObject){
        let tutorialPageViewController = self.parent as! TutorialPageViewController         //parent controller is the tutorialpageviewcontroller
            tutorialPageViewController.nextPageWithIndex(index: index)      //gets next page
        
    }
    
    func enterText(){
        
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
