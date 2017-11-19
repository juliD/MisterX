//
//  TutorialPageViewController.swift
//  Mister X
//
//  Created by admin on 19.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {
    
    let pageHeaders =  ["Entkomme Scotland Yard!", "Finde Mr. X!", "Nutze öffentliche Verkehrsmittel", "Bleib auf dem Laufenden"]
    let pageDescriptions = ["Die bschreibung", "noch ne beschreibung", "bla", "blub"]
    

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

