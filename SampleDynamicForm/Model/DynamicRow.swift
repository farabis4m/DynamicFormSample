//
//  DynamicRow.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 8/20/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

protocol DynamicModel: Codable {
//    var key: String { get set }
//    var tag: String { get set }
//    var title: String? { get set }
//    var value: String? { get set }
}

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

class DynamicRow: DynamicModel {
    var tag: String?
    var title: String?
    var rowType: RowType?
    
    private enum CodingKeys: String, CodingKey {
        case tag
        case title
        case rowType = "type"
    }
    
    var row: BaseRow? {
        return nil
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tag = try container.decodeIfPresent(String.self, forKey: .tag)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        rowType = try container.decodeIfPresent(RowType.self, forKey:  .rowType)
    }
    
    static func decodeContainer(unKeyedContainer: inout UnkeyedDecodingContainer) throws -> DynamicRow? {
        var testContainer = unKeyedContainer
        let row = try? testContainer.decode(DynamicRow.self)
        guard let type = row?.rowType else { return nil }
        
        switch type {
        case .label:
            return try? unKeyedContainer.decode(DynamicLabelRow.self)
        case .textField:
            return try? unKeyedContainer.decode(DynamicTextFieldRow.self)
        case .info:
            return try? unKeyedContainer.decode(DynamicInfoRow.self)
        case .dropDown:
            return try? unKeyedContainer.decode(DynamicDropDownRow.self)
        case .entity:
            return try? unKeyedContainer.decode(DynamicEntityRow.self)
        default:
            return try? unKeyedContainer.decode(DynamicRow.self)
        }
    }
    
    func initializeRow<T: Codable>(row: T.Type, params: [String: Any]) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let decoder = JSONDecoder()
            let row = try decoder.decode(T.self, from: data)
            return row
        } catch {
            print(error)
        }
        return nil
    }
    
}

class DynamicCalendarRow: DynamicRow {
    
    var minDate: String?
    var maxDate: String?
    var dateFormat: String?

    private enum CodingKeys: String, CodingKey {
        case minDate
        case maxDate
        case dateFormat
    }

    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        minDate = try container.decodeIfPresent(String.self, forKey: .minDate)
        
        maxDate = try container.decodeIfPresent(String.self, forKey: .maxDate)
        
        dateFormat = try container.decodeIfPresent(String.self, forKey: .dateFormat)
        
        try super.init(from: decoder)
    }
}

class DynamicInfoRow: DynamicRow {
    
    var  alignment = ""

    private enum CodingKeys: String, CodingKey {
        case alignment
    }

    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.alignment = try container.decodeIfPresent(String.self, forKey: .alignment) ?? ""
        
        try super.init(from: decoder)
    }
    
}

class DynamicLabelRow: DynamicRow {
    
    var key = ""
    
    var value = ""
    
    var orientation = ""

    override var row: BaseRow? {
        
        return DLabelRow(row: self)
        
    }

    private enum CodingKeys: String, CodingKey {
        
        case value
        
        case orientation
        
        case key
        
    }

    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        
        value = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
        
        orientation = try container.decodeIfPresent(String.self, forKey: .orientation) ?? ""
        
        try super.init(from: decoder)
        
    }
    
}

class DynamicTextFieldRow: DynamicRow {
    
    var placeholder = ""
    
    var key = ""
    
    var value = ""
    
    var orientation = ""
    
    var required: Bool?
    
    var validations: [Validation]?
    
    override var row: BaseRow? {
        return DTextFieldRow(row: self)
    }

    private enum CodingKeys: String, CodingKey {
        
        case placeholder
        
        case key
        
        case value
        
        case orientation
        
        case required
        
        case validations
        
    }

    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder) ?? ""
        
        key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        
        value = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
        
        orientation = try container.decodeIfPresent(String.self, forKey: .orientation) ?? ""
        
        required = try container.decodeIfPresent(Bool.self, forKey: .required)
        
        validations = try container.decodeIfPresent([Validation].self, forKey: .validations)
        
        try super.init(from: decoder)
    }
}

class DynamicDropDownRow: DynamicRow {
    var options: [Option] = [Option]()
    var key = ""
    var placeholder = ""
    var orientation = ""
    var required: Bool?
    var validations: [Validation]?
    
    private enum CodingKeys: String, CodingKey {
        case options = "options"
        case placeholder
        case key
        case orientation
        case required
        case validations
    }
    
    override var row: DPickerRow {
        return DPickerRow(row: self)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placeholder     = try container.decode(String.self, forKey: .placeholder)
        key             = try container.decode(String.self, forKey: .key)
        orientation     = try container.decode(String.self, forKey: .orientation)
        required        = try container.decode(Bool.self, forKey: .required)
        validations     = try container.decode([Validation].self, forKey: .validations)
        options = try container.decode([DynamicRow.Option].self, forKey: .options)
        try super.init(from: decoder)
    }
}

class DynamicEntityRow: DynamicRow {
    var key: String?
    var required: Bool?
    var value: String?
    var entityType: EntityType?
    
    private enum CodingKeys: String, CodingKey {
        case key
        case required
        case value
        case entityType
    }
    
    override var row: BaseRow? {
        return DEntityRow(row: self)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        required = try container.decodeIfPresent(Bool.self, forKey: .required)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        entityType = try container.decodeIfPresent(EntityType.self, forKey: .entityType)
        try super.init(from: decoder)
    }
}

extension DynamicRow {
    enum RowType: String, Codable {
        case calendar = "control_calendar"
        case calendarRange = "control_calendarRange"
        case dropDown = "control_Dropdown"
        case dropDownService = "control_DropdownService"
        case label = "control_Label"
        case info = "control_Info"
        case textField = "control_EditText"
        case textView = "control_EditTextView"
        case document = "control_Document"
        case entity = "control_Entity"
        case entityFamily = "control_Entity_Family"
    }
    
    enum RuleType: String, Codable {
        case required
        case regex
        case maxSize
    }
    
    enum EntityType: String, Codable {
        case family = "Family"
        case expense = "Expense"
    }
}

extension DynamicRow {
    struct Validation: Codable {
        var error: String = ""
        var type: RuleType?
        var value: String?
        
        enum CodingKeys: String, CodingKey {
            case error
            case type = "rule"
            case value
        }
    }
    
    struct Option: Codable {
        var code: String?
        var desc: String?
    }
}

