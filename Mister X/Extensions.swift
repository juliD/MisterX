//
//  Extensions.swift
//  Mister X
//
//  Created by Tobias Wittmann on 09.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import Foundation

extension String {
    
    func toArray(separator: String) -> [String] {
        return self.components(separatedBy: separator)
    }
    
    func toNumber() -> NSNumber {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)!
    }
    
}

