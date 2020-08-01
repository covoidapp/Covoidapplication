//
//  GradientBackground.swift
//  iosapp
//
//  Created by Dev Manaktala on 27/07/20.
//  Copyright © 2020 IBM. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    
    func SetGradientBackground(start: UIColor, end: UIColor){
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [end.cgColor, start.cgColor]
        gradient.locations = [0.0,1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        layer.insertSublayer(gradient, at: 0)
    }
}
