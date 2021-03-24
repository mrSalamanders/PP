//
//  SidebarView.swift
//  Autobest
//
//  Created by Владислав Николаев on 04.12.2020.
//

import SwiftUI

struct SidebarView: View {
    
    var body: some View {
        NavigationView {
            List {
                //Caption
                Text("Автосервис")
                    .onAppear(perform: {
                        print("Appear")
                    })
                //Navigation links
                //Replace "WelcomeView" with your destination
                Group{
                    NavigationLink(destination: PriceTableView()) {
                        Label("Прайс", systemImage: "rublesign.circle")
                    }
                    NavigationLink(destination: EmployeeTableView()) {
                        Label("Сотрудники", systemImage: "person.2")
                    }
                    NavigationLink(destination: ClientTableView()) {
                        Label("Клиенты", systemImage: "person.crop.rectangle")
                    }
                    NavigationLink(destination: DetailTableView()) {
                        Label("Склад", systemImage: "bag")
                    }
                    NavigationLink(destination: OrderTableView()) {
                        Label("Заказ-наряды", systemImage: "car.2")
                    }
                }
                //Add some space :)
                Spacer()
                Text("Дополнительно")
                NavigationLink(destination: AnalyticsView()) {
                    Label("Аналитика", systemImage: "newspaper")
                }
//                NavigationLink(destination: WelcomeView()) {
//                    Label("Кастомизация", systemImage: "slider.horizontal.3")
//                }
                //Add some space again!
                Spacer()
                //Divider also looks great!
                Divider()
                NavigationLink(destination: AuthView()) {
                    Label("Учетная запись", systemImage: "person.circle")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Меню")
            //Set Sidebar Width (and height)
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
            
            //Default View on Mac
//            AuthView()
        }
    }
}

// Toggle Sidebar Function
func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
