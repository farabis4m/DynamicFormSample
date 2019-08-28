//
//  DImagePickerCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/20/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

final class DImagePickerCell: BaseImageViewCell {
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    override func update() {
        super.update()
        

        
    }
    
    @IBAction func actionAddImage(_ sender: UIButton) {
        currentRow?.callbackOnRowFocusChanged?()
    }
}

final class DImagePickerRow: BaseImageRow, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<BaseImageViewCell>(nibName: DImagePickerCell.identifier)
        
    }
    
    convenience init(param: [String: Any]) {
        self.init(tag: (param["tag"] as? String) ?? "")
        self.title = (param["title"] as? String) ?? ""
        
    }
    
}



