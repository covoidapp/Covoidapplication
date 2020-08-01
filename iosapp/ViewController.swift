//
//  ViewController.swift
//  iosapp
//

import UIKit
import BMSCore
import IBMCloudAppID

class ViewController: UIViewController {

    @IBOutlet weak var SignUpButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.SetGradientBackground(start: CustomColors.lightblue, end: CustomColors.white)
        SignUpButton.layer.cornerRadius = 10.0
        SignUpButton.layer.masksToBounds = true
        SignUpButton.SetGradientBackground(start: CustomColors.skyblue, end: CustomColors.warmblue)
        // Do any additional setup after loading the view, typically from a nib.
       
        LoginButton.layer.cornerRadius = 10.0
        LoginButton.layer.masksToBounds = true
        LoginButton.SetGradientBackground(start: CustomColors.skyblue, end: CustomColors.warmblue)
       
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func log_in(_ sender: AnyObject){
        let token = TokenStorageManager.sharedInstance.loadStoredToken()
        AppID.sharedInstance.loginWidget?.launch(accessTokenString: token, delegate: SigninDelegate(navigationController: self.navigationController!))
        
    }
    
    @IBAction func sign_up(_ sender: AnyObject){
        AppID.sharedInstance.loginWidget?.launchSignUp(SignupDelegate())
    }

    
    @objc func didBecomeActive(_ notification: Notification) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Opens the specified URL in the default browser.
    func openBrowser(url: String) {
        guard let theURL = URL(string: url) else {
            let alert = UIAlertController(title: "Invalid URL", message: "This button references an invalid URL. Contact IBM Support.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        UIApplication.shared.openURL(theURL)
    }

}
