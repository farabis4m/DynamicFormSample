//
//  DButtonCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/19/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

class DButtonCell: DBaseCell {
    var mode: SelectionMode = .uncheck
    
    @IBOutlet weak var button: UIButton?
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
        
    }
    
    override func update() {
        super.update()
        
        button?.setTitle(row.title, for: .normal)
    }
    
    @IBAction func buttonCheckBox(_ sender: UIButton) {
        guard let currentRow = row as? DButtonRow else { return }
        currentRow.tapAction?()
        currentRow.callbackOnRowFocusChanged?()
        
    }
}

final class DButtonRow: DBaseRow, RowType {
    
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<DBaseCell>(nibName: DButtonCell.identifier)
        
        self.onRowValidationChanged { [weak self]  _ , _ in
            self?.validateRowError()
        }
    }
    
    convenience init(param: [String: Any]) {
        self.init(tag: (param["tag"] as? String) ?? "")
        self.placeholder = (param["hint"] as? String) ?? ""
        self.title = (param["title"] as? String) ?? ""
        if let validation = param["validations"] as? [[String: Any]] {
            self.addValidation(params: validation)
        }
        
    }
}
