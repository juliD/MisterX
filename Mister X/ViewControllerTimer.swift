//
//  ViewControllerTimer.swift
//  Mister X
//
//  Created by Tobias Wittmann on 27.12.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ViewControllerTimer : UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerTextView: UITextView!
    
    let TEN_MINUTES = 10
    let MINUTE = 60
    
    var minutes = 10
    var seconds = 60
    
    var text = "10:00"
    
    var timer = Timer()
    let defaults = UserDefaults.standard
    
    var isMisterX = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let misterx = defaults.string(forKey:"misterX")!
        isMisterX = misterx=="y"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewControllerTimer.updateCounter), userInfo: nil, repeats: true)
        setText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func updateCounter() {
        var sec = ""
        if minutes == TEN_MINUTES && seconds == MINUTE {
            minutes -= 1
        }
        seconds -= 1
        if seconds == 0 {
            sec = "00"
        } else if seconds < TEN_MINUTES {
            sec = "0\(seconds)"
        } else if seconds == MINUTE {
            sec = "00"
        } else {
            sec = "\(seconds)"
        }
        text = "\(minutes):" + sec
        timerLabel.text = text
        if minutes == 0 && seconds == 0 {
            performSegue(withIdentifier: "startGame", sender: self)
        } else if seconds == 0 {
            minutes -= 1
            setSeconds()
        }
    }
    
    private func setSeconds() {
        seconds = MINUTE
    }
    
    private func setText() {
        if(isMisterX){
            timerTextView.text = "MisterX"
        } else {
            timerTextView.text = "Not MisterX"
        }
    }
}

