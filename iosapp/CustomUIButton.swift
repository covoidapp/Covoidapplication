//
//  CustomUIButton.swift
//  iosapp
//
//  Created by Gabriel Valencia on 2/14/20.
//  Copyright © 2020 IBM. All rights reserved.
//

import Foundation
import UIKit

// A custom UIButton that stores a URL string for sending to a browser.
class URLUIBUtton: UIButton {
    // @IBInspectable allows access to custom runtime attributes defined in the storyboard
    @IBInspectable var url: String! {
        didSet {
            // this only appears when debugging in the Xcode deubber console
            print("URLUIBUtton - url = \(self.url ?? "url not set!")")
        }
    }
    
    required init?(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
    }
    
    // Returns the URL that has been set in the UIButton's custom runtime attributes.
    func getURL() -> String {
        return self.url
    }
}
