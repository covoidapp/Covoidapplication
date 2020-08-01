import UIKit
import IBMCloudAppID
import BMSCore

class SignupDelegate : AuthorizationDelegate {
  public func onAuthorizationSuccess(accessToken: AccessToken?, identityToken: IdentityToken?, refreshToken: RefreshToken?, response:Response?) {
     if accessToken == nil && identityToken == nil {
      //email verification is required
      return
     }
   //User authenticated
  }

  public func onAuthorizationCanceled() {
      //Sign up canceled by the user
  }

  public func onAuthorizationFailure(error: AuthorizationError) {
      //Exception occurred
  }

}
