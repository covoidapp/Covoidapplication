//
//  EmployeeSigninDelegate.swift
//  iosapp
//
//  Created by Dev Manaktala on 22/07/20.
//  Copyright © 2020 IBM. All rights reserved.
//

import UIKit
import IBMCloudAppID
import BMSCore



class SigninDelegate: AuthorizationDelegate {
    let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func onAuthorizationSuccess(accessToken: AccessToken?,
                                       identityToken: IdentityToken?,
                                       refreshToken: RefreshToken?,
                                       response:Response?) {
        guard accessToken != nil || identityToken != nil else {
            return
        }
        let view = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingView") as? LoadingScreenView)!
        DispatchQueue.main.async {
            self.navigationController.pushViewController(view, animated: false)
        }
        
        let accessTokenString = (accessToken?.raw)!
        
       
        AppID.sharedInstance.userProfileManager?.getAttributes(accessTokenString: accessTokenString, completionHandler: { (error, attributes) in
            guard error == nil else {
                print("Failed to load selection from profile", error!)
                return
            }

            // we give all non guest users 150 points
            if (attributes?["role"] == nil){
                AppID.sharedInstance.userProfileManager?.setAttribute(key: "role", value: "employee", accessTokenString: accessTokenString, completionHandler: { (error, attributes) in
                    guard error == nil else {
                        print("Failed to assign role", error!)
                        return
                    }
                 print("ASSIGNED")
                })
            }
            print(attributes?["role"] as! String)
            if (attributes?["role"] as! String == "employee") {
                let Nextview  = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoggedInEmployee") as? LoggedInEmployeeView)!
                Nextview.accessToken = accessToken
                Nextview.idToken = identityToken
                print("Employee")
                
                if accessToken!.isAnonymous {
                    TokenStorageManager.sharedInstance.storeToken(token: accessToken!.raw)
                } else {
                    TokenStorageManager.sharedInstance.clearStoredTokens()
                }

                if (refreshToken != nil) {
                    TokenStorageManager.sharedInstance.storeRefreshToken(token: refreshToken!.raw)
                }
                TokenStorageManager.sharedInstance.storeUserId(userId: accessToken!.subject)
                
                DispatchQueue.main.async {
                    self.navigationController.pushViewController(Nextview, animated: false)
                }
                
            }
            else if (attributes?["role"] as! String == "supervisor"){
                let Nextview  = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoggedInSupervisor") as? LoggedInSupervisorView)!
                Nextview.accessToken = accessToken
                Nextview.idToken = identityToken
                
                if accessToken!.isAnonymous {
                    TokenStorageManager.sharedInstance.storeToken(token: accessToken!.raw)
                } else {
                    TokenStorageManager.sharedInstance.clearStoredTokens()
                }

                if (refreshToken != nil) {
                    TokenStorageManager.sharedInstance.storeRefreshToken(token: refreshToken!.raw)
                }
                TokenStorageManager.sharedInstance.storeUserId(userId: accessToken!.subject)
                
                DispatchQueue.main.async {
                    self.navigationController.pushViewController(Nextview, animated: false)
                }
            }
        })

    }

    public func onAuthorizationCanceled() {
        print("cancel")
    }

    public func onAuthorizationFailure(error: AuthorizationError) {
        print("Authorization failure: "+error.localizedDescription)
        SigninDelegate.navigateToLandingView(navigationController: self.navigationController)
    }

    static func navigateToLandingView(navigationController: UINavigationController?) {
        print("Reached")
        let viewCtrl  = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandingViewController") as? ViewController)!
        
        navigationController?.pushViewController(viewCtrl, animated: false)
    }
}


