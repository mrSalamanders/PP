//
//  AnalyticsView.swift
//  Autobest
//
//  Created by Владислав Николаев on 15.12.2020.
//

import SwiftUI
import Firebase

struct AnalyticsView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    var body: some View {
        List {
            HStack {
                Text("Самая дешевая услуга стоит:")
                Spacer()
                Text(String("\(leastExpencivePrice())"))
            }
            HStack {
                Text("Самый дешевый продукт на складе стоит:")
                Spacer()
                Text(String("\(leastExpenciveDetail())"))
            }
            HStack {
                Text("Самый дешевый заказ-наряд обходится в:")
                Spacer()
                Text(String("\(leastExpenciveOrder())"))
            }
            Divider()
            HStack {
                Text("Самая дорогая услуга стоит:")
                Spacer()
                Text(String("\(mostExpencivePrice())"))
            }
            HStack {
                Text("Самый дорогой продукт на складе стоит:")
                Spacer()
                Text(String("\(mostExpenciveDetail())"))
            }
            HStack {
                Text("Самый дорогой заказ-наряд обходится в:")
                Spacer()
                Text(String("\(mostExpenciveOrder())"))
            }
            Divider()
            HStack {
                Text("Самая частая марка авто: ")
                Spacer()
                Text(String("\(mostFreqAuto())"))
            }
            HStack {
                Text("Самая частая услуга: ")
                Spacer()
                Text(String("\(mostFreqPrice())"))
            }
        }
        
        .listStyle(DefaultListStyle())
        .onAppear {
            networkManager.fetchOrders()
        }
        .toolbar{
            //Toggle Sidebar Button
            ToolbarItem(placement: .navigation){
                Button(action: toggleSidebar, label: {
                    Label("Меню", systemImage: "sidebar.left")
                })
            }
        }
    }
    
    func mostFrequent<T: Hashable>(array: [T]) -> (value: T, count: Int)? {

        let counts = array.reduce(into: [:]) { $0[$1, default: 0] += 1 }

        if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
            return (value, count)
        }
        return nil
    }
    
    func mostFreqAuto() -> String {
        var arr = [String]()
        for object in networkManager.clients {
            arr.append(object.autoBrand)
        }
        if let result = mostFrequent(array: arr) {
            print("\(result.value) occurs \(result.count) times")
            return String(result.value)
        }
        return "Нет"
    }
    
    func mostFreqPrice() -> String {
        var arr = [String]()
        for object in networkManager.orders {
            for item in object.priceIDs {
                arr.append(item)
            }
        }
        if let result = mostFrequent(array: arr) {
            print("\(result.value) occurs \(result.count) times")
            return String(networkManager.getPriceById(id: result.value)?.title ?? "Нет")
        }
        return "Нет"
    }
    
    func leastExpencivePrice() -> String {
        var array = [Double]()
        for item in networkManager.prices {
            if item.title == "Покупка" {
                continue
            }
            array.append(item.price)
        }
        if array.isEmpty {
            return "Нет"
        }
        return String("\(array.min()!) ₽")
    }
    
    func mostExpencivePrice() -> String {
        var array = [Double]()
        for item in networkManager.prices {
            array.append(item.price)
        }
        if array.isEmpty {
            return "Нет"
        }
        return String("\(array.max()!) ₽")
    }
    
    func leastExpenciveDetail() -> String {
        var array = [Double]()
        for item in networkManager.details {
            if item.title == "СВОИ детали и расходники" {
                continue
            }
            array.append(item.price)
        }
        if array.isEmpty {
            return "Нет"
        }
        return String("\(array.min()!) ₽")
    }
    
    func mostExpenciveDetail() -> String {
        var array = [Double]()
        for item in networkManager.details {
            array.append(item.price)
        }
        if array.isEmpty {
            return "Нет"
        }
        return String("\(array.max()!) ₽")
    }
    
    func leastExpenciveOrder() -> String {
        var array = [Double]()
        for item in networkManager.orders {
            array.append(networkManager.sumPrices(object: item))
        }
        if array.isEmpty {
            return "Нет"
        }
        return String("\(array.min()!) ₽")
    }
    
    func mostExpenciveOrder() -> String {
        var array = [Double]()
        for item in networkManager.orders {
            array.append(networkManager.sumPrices(object: item))
        }
        if array.isEmpty {
            return "Нет"
        }
        return String("\(array.max()!) ₽")
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
