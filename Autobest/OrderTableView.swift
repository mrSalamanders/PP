//
//  OrderTableView.swift
//  Autobest
//
//  Created by Владислав Николаев on 07.12.2020.
//

import SwiftUI
import Firebase

struct OrderTableView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    @State var showAddView = false
    @State var showEditView = false
    
    @State var currentID = ""
    @State var currentClientID = ""
    @State var currentDateInDate = Date()
    @State var currentDateOutDate = Date()
    @State var currentSelectedStatus = 0
    @State var currentSelectedPrices : [String] = []
    @State var currentSelectedEmployees : [String] = []
    @State var currentSelectedDetailsMap = [String : Int]()
    
    var body: some View {
        List {
            ForEach(networkManager.orders) { o in
                HStack {
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text(networkManager.getClientById(id: o.clientID)?.VIN ?? "VIN")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        Text("Услуги:")
                        ForEach(o.priceIDs, id: \.self) { p in
                            Text(self.networkManager.getPriceById(id: p)?.title ?? "title")
                                .font(.footnote)
                                .opacity(0.5)
                        }
                        Text("Работники:")
                        ForEach(o.employeeIDs, id: \.self) { e in
                            Text(self.networkManager.getEmployeeById(id: e)?.surname ?? "employee")
                                .font(.footnote)
                                .opacity(0.5)
                        }
                        Text("Детали и товары:")
                        ForEach(o.detailIDs.sorted(by: >), id: \.key) { key, value in
                            Text(String("\(self.networkManager.getDetailById(id: key)?.title ?? "detail") – \(value) шт"))
                                .font(.footnote)
                                .opacity(0.5)
                        }
                        Text(String("Статус: \(o.status)"))
                        Text(String("\(o.dateIn) – \(o.dateOut)"))
                        Text("Итого: \(String(format: "%.2f ₽", self.networkManager.sumPrices(object: o)))")
                    })
                    Spacer()
                    
                    Button(action: {
                        if let index = self.networkManager.orders.firstIndex(of: o) {
                            self.networkManager.orders.remove(at: index)
                        }
                        self.networkManager.deleteDoc(object: o)
                    }, label: {
                        Label("Удалить", systemImage: "trash")
                    })
                    .cornerRadius(5)
                    .accentColor(.red)
                    
                    if o.status != "Выполнен" {
                        
                        Button(action: {
                            self.currentID = o.objectID
                            self.currentClientID = o.clientID
                            
                            let di = o.dateIn
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd.MM.yy"
                            self.currentDateInDate = dateFormatter.date(from: di) ?? Date()
                            let dO = o.dateOut
                            self.currentDateOutDate = dateFormatter.date(from: dO) ?? Date()
                            
                            self.currentSelectedStatus = ["В ожидании", "Выполнен", "В работе"].firstIndex(of: o.status) ?? 0
                            self.currentSelectedPrices = o.priceIDs
                            self.currentSelectedEmployees = o.employeeIDs
                            self.currentSelectedDetailsMap = o.detailIDs
                            
                            self.showEditView.toggle()
                        }, label: {
                            Label("Изменить", systemImage: "square.and.pencil")
                        }).sheet(isPresented: $showEditView, content: {
                            EditOrderView(showEditOrderView: $showEditView, obj: $currentID, clientID: $currentClientID, networkManager: networkManager, dateInDate: $currentDateInDate, dateOutDate: $currentDateOutDate, selectedStatus: $currentSelectedStatus, selectedPrices: $currentSelectedPrices, selectedEmployees: $currentSelectedEmployees, selectedDetailsMap: $currentSelectedDetailsMap)
                                .onDisappear() {
                                    self.networkManager.fetchOrders()
                                }
                        })
                        .cornerRadius(5)
                        .accentColor(.green)
                        
                    }
                    
                }
                Divider()
            }
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
                    
                    self.networkManager.fetchOrders()
                    self.showAddView.toggle()
                    
                }, label: {
                    Label("Добавить", systemImage: "plus")
                }).sheet(isPresented: $showAddView, content: {
                    AddOrderView(showAddOrderView: self.$showAddView, networkManager: networkManager)
                        .onDisappear() {
                            self.networkManager.fetchOrders()
                        }
                })
            }
        }
    }
    
}

struct AddOrderView: View {
    
    @Binding var showAddOrderView : Bool
    @ObservedObject var networkManager : NetworkManager
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    @State var dateInDate = Date()
    @State var dateOutDate = Date()
    
    @State var selectedClient = 0
    @State var selectedStatus = 0
    
    let statusList = ["В ожидании", "Выполнен", "В работе"]
    
    @State private var numberOfPeople = 2
    
    @State var selectedPrices: [String] = []
    @State var selectedEmployees: [String] = []
    @State var selectedDetailsMap = [String : Int]()
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        
        LazyVStack {
            Text("Добавить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showAddOrderView.toggle()
                }
            
            Picker(selection: $selectedClient, label: Text("Клиент")) {
                ForEach(0 ..< networkManager.clients.count, id: \.self) { index in
                    Text(String("\(self.networkManager.clients[index].VIN) \(self.networkManager.clients[index].surname) \(self.networkManager.clients[index].autoBrand) \(self.networkManager.clients[index].autoModel)")).tag(index)
                }
            }
            
            HStack {
                Picker(selection: $selectedStatus, label: Text("Статус")) {
                    ForEach(0 ..< statusList.count, id: \.self) { index in
                        Text(String("\(statusList[index])")).tag(index)
                    }
                }
                
                DatePicker(selection: $dateInDate, in: ...Date(), displayedComponents: .date) {
                    Text("Дата приёмки")
                }
                .datePickerStyle(FieldDatePickerStyle())
                
                DatePicker(selection: $dateOutDate, in: Date()..., displayedComponents: .date) {
                    Text("Дата сдачи")
                }
                .datePickerStyle(FieldDatePickerStyle())
            }
            HStack {
                VStack {
                    Text("Услуги")
                    List {
                        ForEach(networkManager.prices) { item in
                            MultipleSelectionRow(title: item.title, isSelected: self.selectedPrices.contains(item.objectID)) {
                                if self.selectedPrices.contains(item.objectID) {
                                    self.selectedPrices.removeAll(where: { $0 == item.objectID })
                                }
                                else {
                                    self.selectedPrices.append(item.objectID)
                                }
                            }
                        }
                    }.frame(height: 200)
                }.frame(maxWidth: 300)
                VStack {
                    Text("Работники")
                    List {
                        ForEach(networkManager.employees) { item in
                            MultipleSelectionRow(title: String("\(item.surname) \(item.position)"), isSelected: self.selectedEmployees.contains(item.objectID)) {
                                if self.selectedEmployees.contains(item.objectID) {
                                    self.selectedEmployees.removeAll(where: { $0 == item.objectID })
                                }
                                else {
                                    self.selectedEmployees.append(item.objectID)
                                }
                            }
                        }
                    }.frame(height: 200)
                }.frame(maxWidth: 300)
                
                VStack {
                    Text("Детали")
                    List {
                        
                        ForEach(networkManager.details) { item in
                            HStack {
                                Text("\(item.title)")
                                Button(action: {
                                    if self.selectedDetailsMap[item.objectID] == nil {
                                        self.selectedDetailsMap[item.objectID] = 0
                                    }
                                    if item.amount > self.selectedDetailsMap[item.objectID]! {
                                        self.selectedDetailsMap[item.objectID]! += 1
                                    }
                                    print(selectedDetailsMap)
                                }, label: {
                                    Label("1", systemImage: "plus")
                                })
                                Button(action: {
                                    if self.selectedDetailsMap[item.objectID] == nil {
                                        self.selectedDetailsMap[item.objectID] = 0
                                    }
                                    if self.selectedDetailsMap[item.objectID]! > 0 {
                                        self.selectedDetailsMap[item.objectID]! -= 1
                                    }
                                    print(selectedDetailsMap)
                                }, label: {
                                    Label("1", systemImage: "minus")
                                })
                            }
                            
                            Text("Количество: \(self.selectedDetailsMap[item.objectID] ?? 0) шт.")
                        }
                        
                    }
                }
            }
            
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                
                if selectedStatus == 1 {
                    for (key, value) in selectedDetailsMap {
                        
                        ref = db.collection("prices").document(key)
                        ref?.updateData([
                            "price": FieldValue.increment(Int64(-1 * value))
                        ]) { error in
                            if let e = error {
                                print("Ошибка")
                                self.reason = e.localizedDescription
                                self.showingAlert = true
                            } else {
                                print("Document updated with ID: \(ref!.documentID)")
                            
                            }
                        }
                        
                    }
                }
                
                let dateInString = dateFormatter.string(from: dateInDate)
                
                let dateOutString = dateFormatter.string(from: dateOutDate)
                
                for (key, value) in selectedDetailsMap {
                    if value == 0 {
                        selectedDetailsMap[key] = nil
                    }
                }
                
                ref = db.collection("orders").addDocument(data: [
                    "clientID": networkManager.clients[selectedClient].objectID,
                    "priceIDs": selectedPrices,
                    "employeeIDs": selectedEmployees,
                    "detailIDs": selectedDetailsMap,
                    
                    "status": statusList[selectedStatus],
                    "dateIn": dateInString,
                    "dateOut": dateOutString
                ]) { error in
                    if let e = error {
                        print("Ошибка")
                        self.reason = e.localizedDescription
                        self.showingAlert = true
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        self.showAddOrderView.toggle()
                    }
                }
            }) {
                Text("Добавить")
                    .accentColor(.blue)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Ошибка"), message: Text(reason), dismissButton: .default(Text("Ок")))
            }
        }
        .frame(minWidth:900)
        .padding()
        
        
    }
}

struct EditOrderView: View {
    
    @Binding var showEditOrderView: Bool
    
    @Binding var obj : String
    @Binding var clientID : String
    
    @ObservedObject var networkManager : NetworkManager
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    @Binding var dateInDate : Date
    @Binding var dateOutDate : Date
    
    @Binding var selectedStatus : Int
    
    let statusList = ["В ожидании", "Выполнен", "В работе"]
    
    @Binding var selectedPrices: [String]
    @Binding var selectedEmployees: [String]
    @Binding var selectedDetailsMap : [String : Int]
    
    @State private var showingAlert = false
    @State private var reason = ""
    
    var body: some View {
        
        LazyVStack {
            Text("Изменить запись")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .onTapGesture {
                    self.showEditOrderView.toggle()
                }
            
            HStack {
                Text(networkManager.getClientById(id: clientID)?.surname ?? "surname")
                Text(networkManager.getClientById(id: clientID)?.name ?? "name")
                Text(networkManager.getClientById(id: clientID)?.VIN ?? "VIN")
            }
            
            
            HStack {
                Picker(selection: $selectedStatus, label: Text("Статус")) {
                    ForEach(0 ..< statusList.count, id: \.self) { index in
                        Text(String("\(statusList[index])")).tag(index)
                    }
                }
                
                DatePicker(selection: $dateInDate, in: ...Date(), displayedComponents: .date) {
                    Text("Дата приёмки")
                }
                .datePickerStyle(FieldDatePickerStyle())
                
                DatePicker(selection: $dateOutDate, in: Date()..., displayedComponents: .date) {
                    Text("Дата сдачи")
                }
                .datePickerStyle(FieldDatePickerStyle())
            }
            HStack {
                VStack {
                    Text("Услуги")
                    List {
                        ForEach(networkManager.prices) { item in
                            MultipleSelectionRow(title: item.title, isSelected: self.selectedPrices.contains(item.objectID)) {
                                if self.selectedPrices.contains(item.objectID) {
                                    self.selectedPrices.removeAll(where: { $0 == item.objectID })
                                }
                                else {
                                    self.selectedPrices.append(item.objectID)
                                }
                            }
                        }
                    }.frame(height: 200)
                }.frame(maxWidth: 300)
                VStack {
                    Text("Работники")
                    List {
                        ForEach(networkManager.employees) { item in
                            MultipleSelectionRow(title: String("\(item.surname) \(item.position)"), isSelected: self.selectedEmployees.contains(item.objectID)) {
                                if self.selectedEmployees.contains(item.objectID) {
                                    self.selectedEmployees.removeAll(where: { $0 == item.objectID })
                                }
                                else {
                                    self.selectedEmployees.append(item.objectID)
                                }
                            }
                        }
                    }.frame(height: 200)
                }.frame(maxWidth: 300)
                
                VStack {
                    Text("Детали")
                    List {
                        
                        ForEach(networkManager.details) { item in
                            HStack {
                                Text("\(item.title)")
                                Button(action: {
                                    if self.selectedDetailsMap[item.objectID] == nil {
                                        self.selectedDetailsMap[item.objectID] = 0
                                    }
                                    if item.amount > self.selectedDetailsMap[item.objectID]! {
                                        self.selectedDetailsMap[item.objectID]! += 1
                                    }
                                    print(selectedDetailsMap)
                                }, label: {
                                    Label("1", systemImage: "plus")
                                })
                                Button(action: {
                                    if self.selectedDetailsMap[item.objectID] == nil {
                                        self.selectedDetailsMap[item.objectID] = 0
                                    }
                                    if self.selectedDetailsMap[item.objectID]! > 0 {
                                        self.selectedDetailsMap[item.objectID]! -= 1
                                    }
                                    print(selectedDetailsMap)
                                }, label: {
                                    Label("1", systemImage: "minus")
                                })
                            }
                            
                            Text("Количество: \(self.selectedDetailsMap[item.objectID] ?? 0) шт.")
                        }
                        
                    }
                }
            }
            
            Button(action: {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                
                if selectedStatus == 1 {
                    for (key, value) in selectedDetailsMap {
                        print("\(key) - \(value)")
                        ref = db.collection("details").document(key)
                        ref?.updateData([
                            "amount": FieldValue.increment(Int64(-1 * value))
                        ]) { error in
                            if let e = error {
                                print("Ошибка")
                                self.reason = e.localizedDescription
                                self.showingAlert = true
                            } else {
                                print("Document updated with ID: \(ref!.documentID)")
                            
                            }
                        }
                        
                    }
                }
                
                let dateInString = dateFormatter.string(from: dateInDate)
                
                let dateOutString = dateFormatter.string(from: dateOutDate)
                
                for (key, value) in selectedDetailsMap {
                    if value == 0 {
                        selectedDetailsMap[key] = nil
                    }
                }
                
                ref = db.collection("orders").document(obj)
                ref?.updateData([
                    "priceIDs": selectedPrices,
                    "employeeIDs": selectedEmployees,
                    "detailIDs": selectedDetailsMap,
                    
                    "status": statusList[selectedStatus],
                    "dateIn": dateInString,
                    "dateOut": dateOutString
                ]) { error in
                    if let e = error {
                        print("Ошибка")
                        self.reason = e.localizedDescription
                        self.showingAlert = true
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        self.showEditOrderView.toggle()
                    }
                }
            }) {
                Text("Изменить")
                    .accentColor(.blue)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Ошибка"), message: Text(reason), dismissButton: .default(Text("Ок")))
            }
        }
        .frame(minWidth:900)
        .padding()
        
        
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                    
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
            
        }
        
    }
}

struct OrderTableView_Previews: PreviewProvider {
    static var previews: some View {
        OrderTableView()
    }
}
