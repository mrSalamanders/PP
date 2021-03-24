//
//  PriceTableView.swift
//  Autobest
//
//  Created by Владислав Николаев on 07.12.2020.
//

import SwiftUI
import Firebase

struct PriceTableView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    @State var currentID : String = ""
    @State var currentTitle : String = ""
    @State var currentPrice : String = ""
    
    @State var showAddView = false
    @State var showEditView = false
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        List {
            ForEach(networkManager.prices) { p in
                HStack {
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text(String(p.title))
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        Text(String(format: "%.2f ₽", p.price))
                    })
                    Spacer()
                    Button(action: {
                        self.currentID = p.objectID
                        if networkManager.isSafeToDelete(id: currentID) {
                            if let index = self.networkManager.prices.firstIndex(of: p) {
                                self.networkManager.prices.remove(at: index)
                            }
                            self.networkManager.deleteDoc(object: p)
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
                        self.currentID = p.objectID
                        self.currentTitle = p.title
                        self.currentPrice = String(format: "%.2f", p.price)
                        self.showEditView.toggle()
                    }, label: {
                        Label("Изменить", systemImage: "square.and.pencil")
                    }).sheet(isPresented: $showEditView, content: {
                        EditPriceView(showEditPriceView: self.$showEditView, obj: $currentID, price: $currentPrice, title: $currentTitle)
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
                    AddPriceView(showAddPriceView: self.$showAddView)
                        .onDisappear() {
                            self.networkManager.fetchPrices()
                        }
                })
            }
        }
    }
    
}

struct AddPriceView: View {
    
    @Binding var showAddPriceView: Bool
    
    @State var price = ""
    @State var title = ""
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        LazyVStack {
            Text("Добавить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showAddPriceView.toggle()
                }
            TextField("Название", text: $title)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Цена", text: $price)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                if let safePrice = Double(price) {
                    ref = db.collection("prices").addDocument(data: [
                        "price": safePrice,
                        "title": title
                    ]) { error in
                        if let e = error {
                            print("Ошибка")
                            self.reason = e.localizedDescription
                            self.showingAlert = true
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            self.showAddPriceView.toggle()
                        }
                    }
                } else {
                    self.reason = "Вы ввели не число."
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

struct EditPriceView: View {
    
    @Binding var showEditPriceView: Bool
    
    @Binding var obj : String
    
    @Binding var price : String
    @Binding var title : String
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        
        return LazyVStack {
            Text("Изменить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showEditPriceView.toggle()
                }
            TextField("Название", text: $title)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            TextField("Цена", text: $price)
                .cornerRadius(7)
                .padding(.leading, 50)
                .padding(.trailing, 50)
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                if let safePrice = Double(price) {
                    ref = db.collection("prices").document(obj)
                    ref?.updateData([
                        "price": safePrice,
                        "title": title
                    ]) { error in
                        if let e = error {
                            print("Ошибка")
                            self.reason = e.localizedDescription
                            self.showingAlert = true
                        } else {
                            print("Document edited with ID: \(ref!.documentID)")
                            self.showEditPriceView.toggle()
                        }
                    }
                } else {
                    self.reason = "Вы ввели не число."
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
//        AddPriceView(showAddPriceView: .constant(true))
//    }
//}

struct PriceTableView_Previews: PreviewProvider {
    static var previews: some View {
        PriceTableView()
    }
}
