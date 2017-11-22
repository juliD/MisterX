//
//  TutorialViewController.swift
//  Mister X
//
//  Created by admin on 19.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!

    
    var index = 0           //for keeping track where you are inside the tutorial
    var headerText = ""
    var descriptionText = ""

    

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = headerText
        descriptionLabel.text = descriptionText
        pageControl.currentPage = index

        //hides or shows the next and start button depending on which page is displayed
        if(index == 3){
            startButton.isHidden = false
            nextButton.isHidden = true
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
        self.dismiss(animated: true, completion: nil)       //when start is clicked dismiss current view
    }
    
    @IBAction func nextClicked(sender: AnyObject){
        let tutorialPageViewController = self.parent as! TutorialPageViewController         //parent controller is the tutorialpageviewcontroller
            tutorialPageViewController.nextPageWithIndex(index: index)      //gets next page
        
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
