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
    
    let DAY = 0
    let MONTH = 1
    let YEAR = 2
    let MINUTE = 3
    let HOUR = 4
    let SECONDS = 5
    
    let TEN_MINUTES = 10
    let FULL_MINUTE = 60
    
    var minutes = 10
    var seconds = 60
    
    var text = "10:00"
    
    var timer = Timer()
    let defaults = UserDefaults.standard
    var currentGame = ""
    var isMisterX = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let misterx = defaults.string(forKey:"misterX")!
        currentGame = defaults.string(forKey: "gameCode")!
        isMisterX = misterx=="y"
        if !isMisterX {
           setTime()
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewControllerTimer.updateCounter), userInfo: nil, repeats: true)
        setText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setTime() {
        let startTime = getStartTime().toArray(separator: ":")
        let currentTime = getCurrentTime().toArray(separator: ":")
        var startTimeInt = [Int]()
        var currentTimeInt = [Int]()
        
        for i in (0 ..< startTime.count) {
            print("i \(startTime[i])")
            print("i \(currentTime[i])")
            startTimeInt[i] = Int(truncating: startTime[i].toNumber())
            currentTimeInt[i] = Int(truncating: currentTime[i].toNumber())
        }
        
        if startTimeInt[DAY] == currentTimeInt[DAY]
            && startTimeInt[MONTH] == currentTimeInt[MONTH]
            && startTimeInt[YEAR] == currentTimeInt[YEAR] {
            
            if (startTimeInt[HOUR] == currentTimeInt[HOUR] && startTimeInt[MINUTE] < currentTimeInt[MINUTE]) {
                let diffenceMinute = currentTimeInt[MINUTE] - startTimeInt[MINUTE]
                if diffenceMinute <= TEN_MINUTES {
                    let differenceSeconds = currentTimeInt[SECONDS] - startTimeInt[SECONDS]
                    minutes -= diffenceMinute
                    seconds -= differenceSeconds
                }
            }
            
        }
        
    }
    
    @objc private func updateCounter() {
        var sec = ""
        if minutes == TEN_MINUTES && seconds == FULL_MINUTE {
            minutes -= 1
        }
        seconds -= 1
        if seconds == 0 {
            sec = "00"
        } else if seconds < TEN_MINUTES {
            sec = "0\(seconds)"
        } else if seconds == FULL_MINUTE {
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
        seconds = FULL_MINUTE
    }
    
    private func setText() {
        if(isMisterX){
            timerTextView.text = "MisterX"
        } else {
            timerTextView.text = "Not MisterX"
        }
    }
    
    fileprivate func getStartTime() -> String{
        var ref: DatabaseReference!
        ref = Database.database().reference()
        var startetAt = ""
        let startetAtRef = ref.child("game").child(currentGame).child("startetAt")
        startetAtRef.observe(.value, with: { (snapshot) in
            //get the single value
            if let value = snapshot.value as? String{
                
                startetAt = value
                
            }
        })
        return startetAt
    }
    
    fileprivate func getCurrentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return "\(day):\(month):\(year):\(hour):\(minutes):\(seconds)"
    }

}

