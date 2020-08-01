//
//  LoadingScreenView.swift
//  iosapp
//
//  Created by Dev Manaktala on 27/07/20.
//  Copyright © 2020 IBM. All rights reserved.
//

import Foundation
import UIKit

class LoadingScreenView: UIViewController{
    
    override func viewDidLoad(){
        self.view.SetGradientBackground(start: CustomColors.lightblue, end: CustomColors.white)
        self.navigationItem.hidesBackButton = true
    }
}
