//
//  ContentView.swift
//  AnonAuth
//
//  Created by Michael Neas on 11/22/20.
//  Copyright © 2020 neas.lease.anonauth. All rights reserved.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State var email: String = ""
    @State var createNewAccount = false
    @State var alert: String = ""
    
    var body: some View {
        VStack {
            Text("Firebase Anonymous First, Email Link Second")
                .bold()
                .multilineTextAlignment(.center)
            VStack(alignment: .leading) {
                Text("Current UID: \(Auth.auth().currentUser?.uid ?? "")")
                Text("Currently Anonymous: \(Auth.auth().currentUser?.isAnonymous == true ? "👍" : "👎" )")
            }
            .padding()
            .font(.system(size: 14))
            
            if Auth.auth().currentUser != nil && Auth.auth().currentUser?.isAnonymous == false {
                Button(action: signOut) {
                    Text("Sign Out")
                }
            } else {
                TextField("Email", text: $email).padding()
                
                Button(action: {
                    attemptSignIn(with: self.email)
                }) {
                    if self.createNewAccount {
                        Text("Create new account and Link")
                    } else {
                        Text("Sign In and Link Email")
                    }
                }.padding()
                
                Button(action: { self.createNewAccount.toggle() }) {
                    if self.createNewAccount {
                        Text("Tap to switch to normal log in.")
                    } else {
                        Text("Tap to switch to create new account.")
                    }
                }
            }
            Spacer()
        }.padding()
    }
    
    private func showMessagePrompt(_ message: String) {
        alert = message
    }
    
    private func attemptSignIn(with email: String) {
        /// query returns a list of sign in methods for this email
        Auth.auth().fetchSignInMethods(forEmail: self.email, completion: { query, error in
            if let error = error {
                print("We got a big problem \(error)")
            } else if query != nil || self.createNewAccount == true {
                let credential = EmailAuthProvider.credential(withEmail: self.email, link: "help.com")
                Auth.auth().currentUser?.link(with: credential, completion: { (authResult, error) in
                    /// Handle common errors mentioned in blog
                    if let error = error {
                        let authError = error as NSError
                        // custom merge step
                        if authError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                            let prevUser = Auth.auth().currentUser
                            print("previous user: \(String(describing: prevUser?.uid))")
                            // try to sign in with credentials
                            Auth.auth().signIn(with: credential, completion: { (authResult, error) in
                                if let error = error {
                                    let authError = error as NSError
                                    print("Error signing in with credential \(authError)")
                                } else {
                                    print("replace all data from \(String(describing: prevUser?.uid)) with \(String(describing: Auth.auth().currentUser?.uid))")
                                    prevUser?.delete(completion: { err in
                                        print("error deleting user: \(String(describing: err))")
                                    })
                                    print("retrieve all data")
                                }
                            })
                        } else {
                            print(authError)
                        }
                    } else {
                        // Easy case, the email was never in our system so the anonymous content becomes associate to this email
                        print("successfully authed and linked: \(String(describing: authResult))")
                    }
                })
            } else {
                // at this point a user needs to be directed to create an account
                print("Email doesn't exist in system, create an account")
                sendSignIn(to: self.email)
            }
        })
    }
    
    private func sendSignIn(to email: String) {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://www.example.com")
        fatalError("CHANGE DOMAIN TO YOUR SPECIFIC DOMAIN or else this demo app will error")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        //actionCodeSettings.setAndroidPackageName("com.example.android", installIfNotAvailable: false, minimumVersion: "12")
        Auth.auth().sendSignInLink(toEmail:email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                self.showMessagePrompt(error.localizedDescription)
                return
            }
            // The link was successfully sent. Inform the user.
            // Save the email locally so you don't need to ask the user for it again
            // if they open the link on the same device.
            UserDefaults.standard.set(email, forKey: "Email")
            self.showMessagePrompt("Check your email for link")
        }
    }
    
    // MARK: Sign out
    private func signOut() {
        do {
            let prevUser = Auth.auth().currentUser
            try Auth.auth().signOut()
            if prevUser?.isAnonymous == true {
                prevUser?.delete(completion: { err in
                    if let error = err {
                        print("Error \(error)")
                    }
                    print("Deleted anonymous user after sign out")
                })
            }
        } catch {
            print("err auth signout")
        }
    }
}
