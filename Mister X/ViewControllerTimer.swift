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
    let HOUR = 3
    let MINUTE = 4
    let SECONDS = 5
    
    let TEN_MINUTES = 1
    let FULL_MINUTE = 1
    
    var minutes = 1
    var seconds = 1
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if minutes <= 0 && seconds <= 0 {
            performSegue(withIdentifier: "startGame", sender: self)
            timer.invalidate()
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
    
    fileprivate func isDayEqual(_ startTimeInt: inout [Int], _ currentTimeInt: inout [Int]) -> Bool {
        return startTimeInt[self.DAY] == currentTimeInt[self.DAY]
            && startTimeInt[self.MONTH] == currentTimeInt[self.MONTH]
            && startTimeInt[self.YEAR] == currentTimeInt[self.YEAR]
    }
    
    fileprivate func isTimeEqual(_ startTimeInt: inout [Int], _ currentTimeInt: inout [Int]) -> Bool {
        return (startTimeInt[self.HOUR] == currentTimeInt[self.HOUR] && startTimeInt[self.MINUTE] < currentTimeInt[self.MINUTE]) || (currentTimeInt[self.HOUR] - startTimeInt[self.HOUR] == 1 && startTimeInt[self.MINUTE] >= 50 && currentTimeInt[self.MINUTE] <= 10)
    }
    
    fileprivate func setTime(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let startetAtRef = ref.child("game").child(currentGame).child("startetAt")
        startetAtRef.observe(.value, with: { (snapshot) in
            //get the single value
            if let value = snapshot.value as? String{
                let startTime = value.toArray(separator: ":")
                let currentTime = self.getCurrentTime().toArray(separator: ":")
                var startTimeInt = [Int]()
                var currentTimeInt = [Int]()
                
                for i in (0 ..< startTime.count) {
                    startTimeInt.append(Int(truncating: startTime[i].toNumber()))
                    currentTimeInt.append(Int(truncating: currentTime[i].toNumber()))
                }
                
                if self.isDayEqual(&startTimeInt, &currentTimeInt) {
                    
                    if self.isTimeEqual(&startTimeInt, &currentTimeInt) {
                        let differenceMinute = self.getDifferenceMinute(currentTimeInt, startTimeInt)
                        
                        if differenceMinute >= self.TEN_MINUTES {
                            self.performSegue(withIdentifier: "startGame", sender: self)
                            self.timer.invalidate()
                        }
                        if differenceMinute < self.TEN_MINUTES {
                            let differenceSeconds = self.getDifferenceSeconds(currentTimeInt, startTimeInt)
                            self.minutes = self.TEN_MINUTES - differenceMinute
                            self.seconds = self.FULL_MINUTE - differenceSeconds
                            print("\(self.minutes):\(self.seconds)")
                            if (self.seconds >= self.FULL_MINUTE) {
                                self.minutes += self.seconds/self.FULL_MINUTE
                                self.seconds -= self.FULL_MINUTE
                            }
                        }
                    }
                    
                }
            }
        })
    }
    
    fileprivate func getDifferenceMinute(_ currentTimeInt: [Int], _ startTimeInt: [Int]) -> Int {
        var minutes = 0
        if currentTimeInt[self.SECONDS] > startTimeInt[self.SECONDS] {
            minutes += 1
        }
        if currentTimeInt[self.MINUTE] < startTimeInt[self.MINUTE] {
            minutes += currentTimeInt[self.MINUTE] + (self.TEN_MINUTES - startTimeInt[self.MINUTE])
        } else {
            minutes += currentTimeInt[self.MINUTE] - startTimeInt[self.MINUTE]
        }
        return minutes
    }
    
    fileprivate func getDifferenceSeconds(_ currentTimeInt: [Int], _ startTimeInt: [Int]) -> Int {
        if currentTimeInt[self.SECONDS] < startTimeInt[self.SECONDS] {
            return currentTimeInt[self.SECONDS] + (self.FULL_MINUTE - startTimeInt[self.SECONDS])
        } else {
            return currentTimeInt[self.SECONDS] - startTimeInt[self.SECONDS]
        }
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
    
    @objc func applicationDidBecomeActive() {
        setTime()
    }

}

