//
//  DynamicResponse.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 9/8/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation

class ServiceResponseForm: DynamicModel {
    var components: [BaseServiceResponse]?
    
    enum CodingKeys: String, CodingKey
    {
        case components
    }
    
    required init(from decoder : Decoder) throws {
        components = []
        
        let container = try decoder.container(keyedBy : CodingKeys.self)
        //        components = try container.decode([BaseServiceResponse].self, forKey: .components)
        
        var unKeyedContainer = try container.nestedUnkeyedContainer(forKey: .components)
        
        while !unKeyedContainer.isAtEnd {
            
            if let row = try? unKeyedContainer.decode(SingleValueResponse.self) {
                components?.append(row)
            }
            else {
                components?.append(try! unKeyedContainer.decode(MultiValueResponse.self))
            }
        }
        
    }
    
    static func decode(params: [String: Any]) -> ServiceResponseForm?  {
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let decoder = JSONDecoder()
            return try decoder.decode(ServiceResponseForm.self, from: data)
        } catch {
            print(error)
        }
        return nil
    }
}

class BaseServiceResponse: Codable {
    var component: String?
    
    private enum CodingKeys: String, CodingKey {
        case component
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        component = try container.decodeIfPresent(String.self, forKey: .component)
    }
}

class SingleValueResponse: BaseServiceResponse {
    var value: String?
    
    private enum CodingKeys: String, CodingKey {
        case value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        try super.init(from: decoder)
    }
}

class MultiValueResponse: BaseServiceResponse {
    var values: [DynamicRow.Option]?
    
    private enum CodingKeys: String, CodingKey {
        case values
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        values = try container.decode([DynamicRow.Option].self, forKey: .values)
        try super.init(from: decoder)
    }
}
