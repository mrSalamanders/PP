//
//  NetworkManager.swift
//  Autobest
//
//  Created by Владислав Николаев on 07.12.2020.
//

import Foundation
import Firebase

class NetworkManager: ObservableObject {
    
    @Published var clients = [Client]()
    
    @Published var prices = [Price]()
    @Published var employees = [Employee]()
    @Published var details = [Detail]()
    
    @Published var orders = [Order]()
    
    let db = Firestore.firestore()
    
    func sumPrices(object: Order) -> Double {
        var sum = 0.0
        for item in object.priceIDs {
            sum += Double(self.getPriceById(id: item)?.price ?? 0)
        }
        for (key, value) in object.detailIDs {
            sum += Double(self.getDetailById(id: key)?.price ?? 0) * Double(value)
        }
        return sum
    }
    
    func getClientById(id: String) -> Client? {
        if let foo = clients.first(where: {$0.objectID == id}) {
           return foo
        } else {
           return nil
        }
    }
    
    func getPriceById(id: String) -> Price? {
        if let foo = prices.first(where: {$0.objectID == id}) {
           return foo
        } else {
           return nil
        }
    }
    
    func getEmployeeById(id: String) -> Employee? {
        if let foo = employees.first(where: {$0.objectID == id}) {
           return foo
        } else {
           return nil
        }
    }
    
    func getDetailById(id: String) -> Detail? {
        if let foo = details.first(where: {$0.objectID == id}) {
           return foo
        } else {
           return nil
        }
    }
    
    func isSafeToDelete(id: String) -> Bool {
        fetchOrders()
        print(id)
        if orders.first(where: {$0.clientID == id}) != nil {
           return false
        }
        
        for object in orders {
            if (object.priceIDs.first(where: {$0 == id}) != nil) || ((object.employeeIDs.first(where: {$0 == id}) != nil)) {
               return false
            }
            if object.detailIDs[id] != nil {
                return false
            }
        }
        print("Save to delete")
        return true
    }
    
    func fetchPrices() {
        db.collection("prices").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.prices.removeAll()
            } else {
                self.prices.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if let title = document.data()["title"], let price = document.data()["price"] {
                        let p = Price(objectID: document.documentID, title: title as! String, price: price as! Double)
                        self.prices.append(p)
                        self.prices.sort { $0.title < $1.title }
                    }
                }
            }
        }
    }
    
    func fetchEmployees() {
        
        db.collection("employees").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.employees.removeAll()
            } else {
                self.employees.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if let surname = document.data()["surname"], let name = document.data()["name"], let position = document.data()["position"], let contacts = document.data()["contacts"] {
                        let e = Employee(objectID: document.documentID, surname: surname  as! String, name: name as! String, position: position as! String, contacts: contacts as! String)
                        self.employees.append(e)
                        self.employees.sort { $0.surname < $1.surname }
                    }
                }
            }
        }
    }
    
    func fetchDetails() {
        
        db.collection("details").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.details.removeAll()
            } else {
                self.details.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if let title = document.data()["title"], let price = document.data()["price"], let amount = document.data()["amount"], let desc = document.data()["desc"], let madeBy = document.data()["madeBy"] {
                        let d = Detail(objectID: document.documentID, title: title  as! String, amount: amount as! Int, desc: desc as! String, price: price as! Double, madeBy: madeBy as! String)
                        self.details.append(d)
                        self.details.sort { $0.title < $1.title }
                    }
                }
            }
        }
    }
    
    func fetchClients() {
        
        db.collection("clients").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.clients.removeAll()
            } else {
                self.clients.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if let surname = document.data()["surname"], let name = document.data()["name"], let autoBrand = document.data()["autoBrand"], let autoModel = document.data()["autoModel"], let VIN = document.data()["VIN"] {
                    let c = Client(objectID: document.documentID, surname: surname  as! String, name: name as! String, autoBrand: autoBrand as! String, autoModel: autoModel as! String, VIN: VIN as! String)
                        self.clients.append(c)
                        self.clients.sort { $0.VIN < $1.VIN }
                    }
                }
            }
        }
    }
    
    func fetchOrders() {
        
        fetchClients()
        fetchPrices()
        fetchEmployees()
        fetchDetails()
        
        db.collection("orders").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.orders.removeAll()
            } else {
                self.orders.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    if let status = document.data()["status"], let dateIn = document.data()["dateIn"], let dateOut = document.data()["dateOut"], let clientID = document.data()["clientID"], let priceIDs = document.data()["priceIDs"], let employeeIDs = document.data()["employeeIDs"], let detailIDs = document.data()["detailIDs"] {
                        
                        let o = Order(objectID: document.documentID, clientID: clientID as! String, priceIDs: priceIDs as! [String], employeeIDs: employeeIDs as! [String], detailIDs: detailIDs as! [String : Int], status: status as! String, dateIn: dateIn as! String, dateOut: dateOut as! String)
                        self.orders.append(o)
                        self.orders.sort { $0.status < $1.status }
                    }
                }
            }
        }
    }
    
    func deleteDoc(object: Any) {
        
        if (object is Price) {
            print("Delete object Price")
            let o = object as! Price
            db.collection("prices").document(o.objectID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
        if (object is Employee) {
            print("Delete object Employee")
            let o = object as! Employee
            db.collection("employees").document(o.objectID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
        if (object is Detail) {
            print("Delete object Detail")
            let o = object as! Detail
            db.collection("details").document(o.objectID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
        if (object is Client) {
            print("Delete object Client")
            let o = object as! Client
            db.collection("clients").document(o.objectID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
        if (object is Order) {
            print("Delete object Order")
            let o = object as! Order
            db.collection("orders").document(o.objectID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
}
