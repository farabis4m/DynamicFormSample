//
//  Form.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 8/21/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation

class DynamicForm: Codable {
    var status: String?
    var data: [DynamicRow]?
    var relations: [Relation]?
    var services: [Service]?
    var subForms: [SubForms]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case relations
        case services
        case subForms = "subForms"
    }
    
    required init(from decoder: Decoder) throws {
        data = []
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        status = try container.decode(String.self, forKey: .status)
        
        relations = try container.decode([Relation].self, forKey: .relations)
        
        services = try container.decode([Service].self, forKey: .services)
        
        subForms = try container.decode([SubForms].self, forKey: .subForms)

        var unKeyedContainer = try container.nestedUnkeyedContainer(forKey: .data)

        while !unKeyedContainer.isAtEnd {
            
            if let row = try DynamicRow.decodeContainer(unKeyedContainer: &unKeyedContainer) {
                data?.append(row)
            }
        }
        
        print("Data rows: \(data)")
    }
    
    static func decode(params: [String: Any]) -> DynamicForm?  {
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let decoder = JSONDecoder()
            return try decoder.decode(DynamicForm.self, from: data)
        } catch {
            print(error)
        }
        return nil
    }
}

class Relation: Codable {
    var component: String?
    var relatedList: [String]?
    var values: [Values]?
    
    enum CodingKeys: String, CodingKey {
        case component
        case relatedList = "related_list"
        case values
    }
    
    struct Values: Codable {
        var code: String?
        var relatedControls: [RelatedControl]?
        
        enum CodingKeys: String, CodingKey {
            case code
            case relatedControls = "related_controls"
        }
    }
    
    struct RelatedControl: Codable {
        var component: String?
        var values: [String]?
    }
}

class SubForms: Codable {
    
    var control: String?
    
    var forms: [DynamicRow]?
    
    enum CodingKeys: String, CodingKey {
        
        case control = "Control"
        
        case forms = "Forms"
    }

    required init(from decoder: Decoder) throws {
        
        forms = []
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        control = try container.decode(String.self, forKey: .control)
        
        var unKeyedContainer = try container.nestedUnkeyedContainer(forKey: .forms)
        
        while !unKeyedContainer.isAtEnd {
            
            if let row = try DynamicRow.decodeContainer(unKeyedContainer: &unKeyedContainer) {
                
                forms?.append(row)
            }
        }
    }
}

class Service: Codable {
    var relatedComponents: [String]?
    var endPoint: String?
}
