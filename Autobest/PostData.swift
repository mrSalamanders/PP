//
//  PostData.swift
//  Autobest
//
//  Created by Владислав Николаев on 07.12.2020.
//

import Foundation
import Firebase

struct Price: Identifiable, Equatable, Hashable {
    var id: String {
        return objectID
    }
    let objectID: String
    let title: String
    let price: Double
}

struct Employee: Identifiable, Equatable, Hashable   {
    var id: String {
        return objectID
    }
    let objectID: String
    let surname: String
    let name: String
    let position: String
    let contacts: String
}

struct Detail: Identifiable, Equatable, Hashable   {
    var id: String {
        return objectID
    }
    let objectID: String
    let title: String
    let amount: Int
    let desc: String
    let price: Double
    let madeBy: String
}

struct Client: Identifiable, Equatable, Hashable  {
    var id: String {
        return objectID
    }
    let objectID: String
    let surname: String
    let name: String
    let autoBrand: String
    let autoModel: String
    let VIN: String
}

struct Order: Identifiable, Equatable, Hashable  {
    var id: String {
        return objectID
    }
    let objectID: String
    
    let clientID: String
    let priceIDs: [String]
    let employeeIDs: [String]
    let detailIDs: [String : Int]
    
    let status: String
    let dateIn: String
    let dateOut: String
}
