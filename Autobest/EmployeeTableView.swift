//
//  EmployeeTableView.swift
//  Autobest
//
//  Created by Владислав Николаев on 07.12.2020.
//

import SwiftUI
import Firebase

struct EmployeeTableView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    @State var currentID : String = ""
    @State var currentSurname : String = ""
    @State var currentName : String = ""
    @State var currentPosition : String = ""
    @State var currentContacts : String = ""
    
    @State var showAddView = false
    @State var showEditView = false
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        List {
            ForEach(networkManager.employees) { e in
                HStack {
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text(String("\(e.surname) \(e.name)"))
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        Text(String(e.position))
                        Text(String(e.contacts))
                    })
                    Spacer()
                    Button(action: {
                        self.currentID = e.objectID
                        if networkManager.isSafeToDelete(id: currentID) {
                            if let index = self.networkManager.employees.firstIndex(of: e) {
                                self.networkManager.employees.remove(at: index)
                            }
                            self.networkManager.deleteDoc(object: e)
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
                        self.currentID = e.objectID
                        self.currentSurname = e.surname
                        self.currentName = e.name
                        self.currentPosition = e.position
                        self.currentContacts = e.contacts
                        self.showEditView.toggle()
                    }, label: {
                        Label("Изменить", systemImage: "square.and.pencil")
                    }).sheet(isPresented: $showEditView, content: {
                        EditEmployeeView(showEditEmployeeView: self.$showEditView, obj: $currentID, surname: $currentSurname, name: $currentName, position: $currentPosition, contacts: $currentContacts)
                            .onDisappear() {
                                self.networkManager.fetchOrders()
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
                    AddEmployeeView(showAddEmployeeView: self.$showAddView)
                        .onDisappear() {
                            self.networkManager.fetchEmployees()
                        }
                })
            }
        }
    }
    
}

struct AddEmployeeView: View {
    
    @Binding var showAddEmployeeView: Bool
    
    @State var surname = ""
    @State var name = ""
    @State var position = ""
    @State var contacts = ""
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        LazyVStack {
            Text("Добавить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showAddEmployeeView.toggle()
                }
            TextField("Фамилия", text: $surname)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Имя", text: $name)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Должность", text: $position)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Контактные данные", text: $contacts)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                surname = surname.trimmingCharacters(in: .whitespacesAndNewlines)
                name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                position = position.trimmingCharacters(in: .whitespacesAndNewlines)
                print(surname)
                print(name)
                print(position)
                if (surname != "" && name != "" && position != "") {
                    ref = db.collection("employees").addDocument(data: [
                        "surname": surname,
                        "name": name,
                        "position": position,
                        "contacts": contacts
                    ]) { error in
                        if let e = error {
                            print("Ошибка")
                            self.reason = e.localizedDescription
                            self.showingAlert = true
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            self.showAddEmployeeView.toggle()
                        }
                    }
                } else {
                    self.reason = "Фамилия, Имя и Должность – обязательные поля"
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

struct EditEmployeeView: View {
    
    @Binding var showEditEmployeeView: Bool
    
    @Binding var obj : String
    
    @Binding var surname : String
    @Binding var name : String
    @Binding var position : String
    @Binding var contacts : String
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        
        return LazyVStack {
            Text("Изменить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showEditEmployeeView.toggle()
                }
            TextField("Фамилия", text: $surname)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Имя", text: $name)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Должность", text: $position)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Контактные данные", text: $contacts)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                surname = surname.trimmingCharacters(in: .whitespacesAndNewlines)
                name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                position = position.trimmingCharacters(in: .whitespacesAndNewlines)
                if (surname != "" && name != "" && position != "") {
                    ref = db.collection("employees").document(obj)
                    ref?.updateData([
                        "surname": surname,
                        "name": name,
                        "position": position,
                        "contacts": contacts
                    ]) { error in
                        if let e = error {
                            print("Ошибка")
                            self.reason = e.localizedDescription
                            self.showingAlert = true
                        } else {
                            print("Document edited with ID: \(ref!.documentID)")
                            self.showEditEmployeeView.toggle()
                        }
                    }
                } else {
                    self.reason = "Фамилия, Имя и Должность – обязательные поля"
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
//        AddEmployeeView(showAddEmployeeView: .constant(true))
//    }
//}

struct EmployeeTableView_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeTableView()
    }
}
