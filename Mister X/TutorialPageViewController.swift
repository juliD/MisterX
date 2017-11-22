//
//  TutorialPageViewController.swift
//  Mister X
//
//  Created by admin on 19.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {
    
    
    let pageHeaders =  ["Entkomme Scotland Yard!", "Ziel", "Standort mitteilen", "Bleib auf dem Laufenden"]
    let pageDescriptions = ["Versuche deinen Gegenspielern zu entkommen indem du öffentliche Verkehrsmittel benutzt", "Wenn du 2 Stunden lang unentdeckt fliehen konntest, hast du gewonnen!", "Alle 10 Minuten wird dein Standort mit den Mitspielern geteilt, damit diese wissen, an welher Station du gerade warst", "Sieh was im Chat los ist und werde über den Standort von Mister X über Push Benachrichtigungen benachrichtigt."]
    let colors = [UIColor(rgb: 0xACD8AA),UIColor(rgb: 0xAFC6471),UIColor(rgb: 0xC5D9E2),UIColor(rgb: 0xFFCAB1)]
    


    //can generate a UIColor from a hexcode
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        if let startTutorialViewController = self.viewControllerAtIndex(index: 0){
            setViewControllers([startTutorialViewController], direction: .forward, animated: true, completion: nil)
        }

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
    
    func nextPageWithIndex(index: Int){
        //gets nextPage from the current index
        if let nextTutorialViewController = self.viewControllerAtIndex(index: index+1){
            setViewControllers([nextTutorialViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func viewControllerAtIndex(index: Int) -> TutorialViewController?{
        if (index == NSNotFound || index < 0 || index > pageDescriptions.count-1){
            return nil
        }else if let tutorialViewController = storyboard?.instantiateViewController(withIdentifier: "TutorialViewController") as? TutorialViewController{
            //fill labels with text of current page
            tutorialViewController.descriptionText = pageDescriptions[index]
            tutorialViewController.headerText = pageHeaders[index]
            tutorialViewController.index = index
            tutorialViewController.view.backgroundColor = colors[index]
            return tutorialViewController
        }
        return nil
        
    }
    
    
}

extension TutorialPageViewController : UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialViewController).index
        index-=1
        return self.viewControllerAtIndex(index: index)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialViewController).index
        index+=1
        return self.viewControllerAtIndex(index: index)
    }
}


extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((rgb & 0xff0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00ff00) >>  8) / 255
        let b = CGFloat((rgb & 0x0000ff)      ) / 255
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
}


