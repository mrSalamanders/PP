//
//  AutobestApp.swift
//  Autobest
//
//  Created by Владислав Николаев on 03.12.2020.
//

import SwiftUI
import Firebase

@main
struct AutobestApp: App {
    
    // Create App
    init() {
        initFB()
        
//        logOut()
//        logIn()
    }
    
    
    var body: some Scene {
        WindowGroup {
//            ClientTableView()
            SidebarView()
            
        }
    }
    
    func initFB() {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        print(db)
    }
    
    
//    func logOut() {
//        let firebaseAuth = Auth.auth()
//        do {
//          try firebaseAuth.signOut()
//        } catch let signOutError as NSError {
//          print ("Error signing out: %@", signOutError)
//        }
//    }
//
//    func logIn() {
//
//        let email = "1@2.ru"
//        let password = "1234567"
//
//        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//            if let e = error {
//                print(e)
//            } else {
//                print("Succesfully logged in")
//            }
//        }
//    }
    
}
