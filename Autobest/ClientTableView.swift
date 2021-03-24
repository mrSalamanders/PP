//
//  ClientTableView.swift
//  Autobest
//
//  Created by Владислав Николаев on 07.12.2020.
//

import SwiftUI
import Firebase

struct ClientTableView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    @State var currentID : String = ""
    @State var currentSurname : String = ""
    @State var currentName : String = ""
    @State var currentAutoBrand : String = ""
    @State var currentAutoModel : String = ""
    @State var currentVIN : String = ""
    
    @State var showAddView = false
    @State var showEditView = false
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        List {
            ForEach(networkManager.clients) { c in
                HStack {
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text(String(c.VIN))
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        Text(String("\(c.surname) \(c.name)"))
                        Text(String("\(c.autoBrand) \(c.autoModel)"))
                    })
                    Spacer()
                    Button(action: {
                        self.currentID = c.objectID
                        if networkManager.isSafeToDelete(id: currentID) {
                            if let index = self.networkManager.clients.firstIndex(of: c) {
                                self.networkManager.clients.remove(at: index)
                            }
                            self.networkManager.deleteDoc(object: c)
                        } else {
                            self.reason = "Нельзя удалять объекты, которые связаны с другими сущностями."
                            self.showingAlert = true
                        }
                    }, label: {
                        Label("Удалить", systemImage: "trash")
                    })
                    
                    .cornerRadius(5)
                    .accentColor(.red)
                    Button(action: {
                        self.currentID = c.objectID
                        self.currentSurname = c.surname
                        self.currentName = c.name
                        self.currentAutoBrand = c.autoBrand
                        self.currentAutoModel = c.autoModel
                        self.currentVIN = c.VIN
                        self.showEditView.toggle()
                    }, label: {
                        Label("Изменить", systemImage: "square.and.pencil")
                    }).sheet(isPresented: $showEditView, content: {
                        EditClientView(showEditClientView: self.$showEditView, obj: $currentID, surname: $currentSurname, name: $currentName, autoBrand: $currentAutoBrand, autoModel: $currentAutoModel, VIN: $currentVIN)
                            .onDisappear() {
                                self.networkManager.fetchClients()
                            }
                    })
                    .cornerRadius(5)
                    .accentColor(.green)
                }
                Divider()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Ошибка"), message: Text(reason), dismissButton: .default(Text("Ок")))
        }
        .onAppear {
            self.networkManager.fetchOrders()
        }
        .toolbar{
            //Toggle Sidebar Button
            ToolbarItem(placement: .navigation){
                Button(action: toggleSidebar, label: {
                    Label("Меню", systemImage: "sidebar.left")
                })
            }
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    self.showAddView.toggle()
                }, label: {
                    Label("Добавить", systemImage: "plus")
                }).sheet(isPresented: $showAddView, content: {
                    AddClientView(showAddClientView: self.$showAddView)
                        .onDisappear() {
                            self.networkManager.fetchOrders()
                        }
                })
            }
        }
    }
    
}

struct AddClientView: View {
    
    @Binding var showAddClientView: Bool
    
    @State var surname = ""
    @State var name = ""
    @State var autoBrand = ""
    @State var autoModel = ""
    @State var VIN = ""
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        LazyVStack {
            Text("Добавить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showAddClientView.toggle()
                }
            TextField("Фамилия", text: $surname)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Имя", text: $name)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Марка авто", text: $autoBrand)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Модель авто", text: $autoModel)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("VIN-номер", text: $VIN)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                surname = surname.trimmingCharacters(in: .whitespacesAndNewlines)
                name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                VIN = VIN.trimmingCharacters(in: .whitespacesAndNewlines)
                print(surname)
                print(name)
                print(VIN)
                if (surname != "" && name != "" && VIN != "") {
                    if VIN.count == 17 {
                        ref = db.collection("clients").addDocument(data: [
                            "surname": surname,
                            "name": name,
                            "autoBrand": autoBrand,
                            "autoModel": autoModel,
                            "VIN": VIN
                        ]) { error in
                            if let e = error {
                                print("Ошибка")
                                self.reason = e.localizedDescription
                                self.showingAlert = true
                            } else {
                                print("Document added with ID: \(ref!.documentID)")
                                self.showAddClientView.toggle()
                            }
                        }
                    } else {
                        self.reason = "Некорректная длина VIN. Необходимо 17 символов."
                        self.showingAlert = true
                    }
                } else {
                    self.reason = "Фамилия, Имя и VIN-номер – обязательные поля"
                    self.showingAlert = true
                }
            }) {
                Text("Добавить")
                    .accentColor(.blue)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Ошибка"), message: Text(reason), dismissButton: .default(Text("Ок")))
            }
        }
        .padding()
    }
}

struct EditClientView: View {
    
    @Binding var showEditClientView: Bool
    
    @Binding var obj : String
    
    @Binding var surname : String
    @Binding var name : String
    @Binding var autoBrand : String
    @Binding var autoModel : String
    @Binding var VIN : String
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        
        return LazyVStack {
            Text("Изменить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showEditClientView.toggle()
                }
            TextField("Фамилия", text: $surname)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Имя", text: $name)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Марка авто", text: $autoBrand)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Модель авто", text: $autoModel)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("VIN-номер", text: $VIN)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                surname = surname.trimmingCharacters(in: .whitespacesAndNewlines)
                name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                VIN = VIN.trimmingCharacters(in: .whitespacesAndNewlines)
                print(surname)
                print(name)
                print(VIN)
                if (surname != "" && name != "" && VIN != "") {
                    ref = db.collection("clients").document(obj)
                    ref?.updateData([
                        "surname": surname,
                        "name": name,
                        "autoBrand": autoBrand,
                        "autoModel": autoModel,
                        "VIN": VIN
                    ]) { error in
                        if let e = error {
                            print("Ошибка")
                            self.reason = e.localizedDescription
                            self.showingAlert = true
                        } else {
                            print("Document edited with ID: \(ref!.documentID)")
                            self.showEditClientView.toggle()
                        }
                    }
                } else {
                    self.reason = "Фамилия, Имя и VIN-номер – обязательные поля"
                    self.showingAlert = true
                }
            }) {
                Text("Изменить")
                    .accentColor(.blue)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Ошибка"), message: Text(reason), dismissButton: .default(Text("Ок")))
            }
        }
        .padding()
    }
}

//struct ModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddClientView(showAddClientView: .constant(true))
//    }
//}

struct ClientTableView_Previews: PreviewProvider {
    static var previews: some View {
        ClientTableView()
    }
}
