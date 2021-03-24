//
//  AuthView.swift
//  Autobest
//
//  Created by Владислав Николаев on 04.12.2020.
//

import SwiftUI
import Firebase

struct AuthView: View {
    
    @State var isLogged : Bool = false
    
    @State var email : String = ""
    @State var password : String = ""
    
    @State private var showingAlertIncorrectLogin = false
    @State private var reason = ""
    
    var body: some View {
        LazyVStack {
            Text("Autobest 2020")
                .onAppear(perform: {
                    checkAuth()
                })
            if !isLogged {
                Text("Авторизация")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                TextField("Электронная почта", text: $email)
                    .cornerRadius(7)
                    .frame(maxWidth: 200)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                    
                SecureField("Пароль", text: $password)
                    .cornerRadius(7)
                    .frame(maxWidth: 200)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                
                Button(action: {
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let e = error {
                            print("Ошибка")
                            self.reason = e.localizedDescription
                            self.showingAlertIncorrectLogin = true
                        } else {
                            print("Успешный вход \(email) и \(password)")
                            checkAuth()
                        }
                    }
                }) {
                    Text("Войти")
                        .accentColor(.blue)
                }
                .alert(isPresented: $showingAlertIncorrectLogin) {
                    Alert(title: Text("Ошибка"), message: Text(reason), dismissButton: .default(Text("Ок")))
                }
            } else {
                Text("Вы уже авторизованы")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                if let safeEmail = Auth.auth().currentUser?.email {
                    Text("Под аккаунтом \(safeEmail)")
                        .cornerRadius(7)
                        .padding(.leading, 50)
                        .padding(.trailing, 50)
                }
                Button(action: {
                    let firebaseAuth = Auth.auth()
                    do {
                      try firebaseAuth.signOut()
                    } catch let signOutError as NSError {
                      print ("Error signing out: %@", signOutError)
                    }
                    checkAuth()
                }) {
                    Text("Выйти")
                        .accentColor(.blue)
                }
            }
        }
        .padding()
        .toolbar{
            //Toggle Sidebar Button
            ToolbarItem(placement: .navigation){
                Button(action: toggleSidebar, label: {
                    Label("Меню", systemImage: "sidebar.left")
                })
            }
        }
    }
    
    func checkAuth() {
        if Auth.auth().currentUser == nil {
            isLogged = false
        } else {
            isLogged = true
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
