//
//  DetailTableView.swift
//  Autobest
//
//  Created by Владислав Николаев on 07.12.2020.
//

import SwiftUI
import Firebase

struct DetailTableView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    @State var currentID : String = ""
    @State var currentTitle : String = ""
    @State var currentPrice : String = ""
    @State var currentAmount : String = ""
    @State var currentDesc : String = ""
    @State var currentMadeBy : String = ""
    
    @State var showAddView = false
    @State var showEditView = false
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        List {
            ForEach(networkManager.details) { d in
                HStack {
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text(String(d.title))
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        Text(String(format: "%.2f ₽", d.price))
                        Text(String("\(d.amount) шт."))
                        Text(String(d.madeBy))
                            .font(.footnote)
                            .opacity(0.5)
                        Spacer()
                        Text(String(d.desc))
                    })
                    Spacer()
                    Button(action: {
                        self.currentID = d.objectID
                        if networkManager.isSafeToDelete(id: currentID) {
                            if let index = self.networkManager.details.firstIndex(of: d) {
                                self.networkManager.details.remove(at: index)
                            }
                            self.networkManager.deleteDoc(object: d)
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
                        self.currentID = d.objectID
                        self.currentTitle = d.title
                        self.currentPrice = String(format: "%.2f", d.price)
                        self.currentAmount = String(d.amount)
                        self.currentDesc = d.desc
                        self.currentMadeBy = d.madeBy
                        self.showEditView.toggle()
                    }, label: {
                        Label("Изменить", systemImage: "square.and.pencil")
                    }).sheet(isPresented: $showEditView, content: {
                        EditDetailView(showEditDetailView: self.$showEditView, obj: $currentID, title: $currentTitle, amount: $currentAmount, desc: $currentDesc, price: $currentPrice, madeBy: $currentMadeBy)
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
                    AddDetailView(showAddDetailView: self.$showAddView)
                        .onDisappear() {
                            self.networkManager.fetchDetails()
                        }
                })
            }
        }
    }
    
}

struct AddDetailView: View {
    
    @Binding var showAddDetailView: Bool
    
    @State var title = ""
    @State var amount = ""
    @State var desc = ""
    @State var price = ""
    @State var madeBy = ""
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        LazyVStack {
            Text("Добавить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showAddDetailView.toggle()
                }
            TextField("Название", text: $title)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Количество", text: $amount)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Описание", text: $desc)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Цена", text: $price)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Произведен", text: $madeBy)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                if let safePrice = Double(price) {
                    if let safeAmount = Int(amount) {
                        if safeAmount >= 0 {
                            ref = db.collection("details").addDocument(data: [
                                "title": title,
                                "amount": safeAmount,
                                "desc": desc,
                                "price": safePrice,
                                "madeBy": madeBy
                            ]) { error in
                                if let e = error {
                                    print("Ошибка")
                                    self.reason = e.localizedDescription
                                    self.showingAlert = true
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                    self.showAddDetailView.toggle()
                                }
                            }
                        } else {
                            self.reason = "Неправильно указано количество."
                            self.showingAlert = true
                        }
                    }
                } else {
                    self.reason = "Неправильно указана цена."
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

struct EditDetailView: View {
    
    @Binding var showEditDetailView: Bool
    
    @Binding var obj : String
    
    @Binding var title : String
    @Binding var amount : String
    @Binding var desc : String
    @Binding var price : String
    @Binding var madeBy : String
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        
        return LazyVStack {
            Text("Изменить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showEditDetailView.toggle()
                }
            TextField("Название", text: $title)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Количество", text: $amount)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Описание", text: $desc)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Цена", text: $price)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Произведен", text: $madeBy)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                if let safePrice = Double(price) {
                    if let safeAmount = Int(amount) {
                        if safeAmount >= 0 {
                            ref = db.collection("details").document(obj)
                            ref?.updateData([
                                "title": title,
                                "amount": safeAmount,
                                "desc": desc,
                                "price": safePrice,
                                "madeBy": madeBy
                            ]) { error in
                                if let e = error {
                                    print("Ошибка")
                                    self.reason = e.localizedDescription
                                    self.showingAlert = true
                                } else {
                                    print("Document edited with ID: \(ref!.documentID)")
                                    self.showEditDetailView.toggle()
                                }
                            }
                        } else {
                            self.reason = "Неправильно указанн количество"
                            self.showingAlert = true
                        }
                    }
                } else {
                    self.reason = "Неправильно указана цена"
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
//        AddDetailView(showAddDetailView: .constant(true))
//    }
//}

struct DetailTableView_Previews: PreviewProvider {
    static var previews: some View {
        DetailTableView()
    }
}
