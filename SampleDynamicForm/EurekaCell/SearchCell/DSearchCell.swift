//
//  DSearchCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/18/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka


class DSearchCell: DBaseCell {
    
    @IBOutlet weak var searchTextField: SearchTextField?
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    override func update() {
        super.update()
        
        guard let row = row as? DSearchRow else { return }
        searchTextField?.keyboardType = row.keyboardType
        searchTextField?.isUserInteractionEnabled = row.isEditable
        
        searchTextField?.accessibilityIdentifier = "textField"
        titleLabel?.accessibilityIdentifier = "labelTitle"
        titleLabel?.text = row.title
        searchTextField?.placeholder = row.placeholder
        searchTextField?.minCharactersNumberToStartFiltering = row.minCharactersNumberToStartFiltering
    }
}

final class DSearchRow: DBaseRow, RowType {
    
    public var updatedList: [String]? {
        didSet {
            if let currentCell = cell as? DSearchCell {
            currentCell.searchTextField?.updateList(updatedList ?? [])
            }
        }
    }
    
    var minCharactersNumberToStartFiltering = 1
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<DBaseCell>(nibName: DSearchCell.identifier)
        
        self.onRowValidationChanged { [weak self]  _ , _ in
            self?.validateRowError()
        }
    }
    
    convenience init(param: [String: Any]) {
        self.init(tag: (param["tag"] as? String) ?? "")
        self.placeholder = (param["hint"] as? String) ?? ""
        self.title = (param["title"] as? String) ?? ""
        self.minCharactersNumberToStartFiltering =  Int((param["threshold"] as? String) ?? "") ?? 0
        if let validation = param["validations"] as? [[String: Any]] {
            self.addValidation(params: validation)
        }
        if let arrayValues = (param["values"]) as? [[String:String]] {
            createListableValues(arrayValues: arrayValues)
        }
        updatedList = values.map { $0.listName }
        if let currentCell = cell as? DSearchCell {
            currentCell.searchTextField?.updateList(updatedList ?? [])
        }
    }
    
    
}
