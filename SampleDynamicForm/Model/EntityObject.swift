//
//  EntityObject.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 8/29/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation

class Entity: Codable {
    var extraFields: [String: String]?
    
    static func decode(entityType: DynamicRow.EntityType, params: [String: Any]) -> Entity?  {
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let decoder = JSONDecoder()
            
            switch  entityType {
            case .expense:
                return try? decoder.decode(Expense.self, from: data)
            case .family:
                return try? decoder.decode(Family.self, from: data)
            }
        } catch {
            print(error)
        }
        return nil
    }
}

class Expense: Entity {
    var expenseType: String?
    var date: String?
//    var reason: String?
    
    enum CodingKeys: String, CodingKey {
        
        case expenseType = "expense"
        case date
//        case reason
        
        static let cases = ["expense", "date"]//, "reason"]
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        expenseType = try container.decodeIfPresent(String.self, forKey: .expenseType)
        date = try container.decodeIfPresent(String.self, forKey: .date)
//        reason = try container.decodeIfPresent(String.self, forKey: .reason)
        try super.init(from: decoder)
    }
}

class Family: Entity {
    var family: String?
    
    enum CodingKeys: String, CodingKey {
        case family
        
        static let cases = ["family"]
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        family = try container.decodeIfPresent(String.self, forKey: .family)
        try super.init(from: decoder)
    }
}
