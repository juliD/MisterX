//
//  PersonControler.swift
//  Mister X
//
//  Created by Tobias Wittmann on 10.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PersonControler: UIStackView {
    
    private var personViews = [UIImageView]()
    
    var persons = 0 {
        didSet{
            setupPersons()
        }
    }
    
    @IBInspectable var personSize: CGSize = CGSize(width: 75.0, height: 75.0) {
        didSet {
            setupPersons()
        }
    }
    
    @IBInspectable var personCount: Int = 4 {
        didSet {
            setupPersons()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPersons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupPersons()
    }
    
    private func setupPersons() {
        for imageView in personViews {
            removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }
        personViews.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let filledMan = UIImage(named: "man-filled", in: bundle, compatibleWith: self.traitCollection)
        let emptyMan = UIImage(named:"man-empty", in: bundle, compatibleWith: self.traitCollection)
        
        
        for index in 0..<personCount {
            // Create the imageView
            let imageView = UIImageView()
            
            // Set image
            
            if persons == 0 {
                imageView.image = emptyMan
            } else if persons == 1 {
                if index == 0 {
                    imageView.image = filledMan
                } else {
                    imageView.image = emptyMan
                }
            } else if persons == 2 {
                if index == 0 || index == 1 {
                    imageView.image = filledMan
                } else {
                    imageView.image = emptyMan
                }
            } else if persons == 3 {
                if index == 0 || index == 1 || index == 2 {
                    imageView.image = filledMan
                } else {
                    imageView.image = emptyMan
                }
            } else {
                imageView.image = filledMan
            }
            
            // Add constraints
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: personSize.height).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: personSize.width).isActive = true
            
            
            // Add the imageView to the stack
            addArrangedSubview(imageView)
            
            // Add the new imageView to the person imageView array
            personViews.append(imageView)
        }
        
    }
    
}
