//
//  BaseFieldRow.swift
//  SampleDynamicForm
//
//  Created by Jafar khan on 6/13/19.
//  Copyright © 2019 Farabi Technology Middle East. All rights reserved.
//

import Foundation
import Eureka

class BaseFieldRow<Cell: CellType>: FormatteableRow<Cell> where Cell: BaseCell, Cell: TextInputCell {
	
	// placeholder text
	var placeholder: String?
	
	var titleText: String?
	
	// Place holder image to be displayed to the left of the text field
	var placeHolderImage: UIImage?
	
	var maxLength: Int?
	
	var isEditable = true
	
	var isSecureEntry = false
		
	var keyboardType = UIKeyboardType.default
	
	var isRequired = true
	
	var shouldAllowAllCharacters = false
	
	var disableCopyPaste = false
	
	var isEnabled = true
	
	var isRealTimeValidation = false
	
	var realTimeRegex: String?
	
	var needsValidation = true
	
	var needCurrencyFormatting = false
		
	required init(tag: String?) {
		super.init(tag: tag)
	}
	
	func baseRowValidation() {
	}
}

enum Rule: String {
    case required = "required"
    case regex = "regex"
    case dateFormat = "dateFormat"
    
    var value: String {
        switch self {
        case .regex, .dateFormat: return "value"
        case .required: return ""
        }
    }
    
    var message: String {
        switch self {
        case .required, .regex, .dateFormat: return "error"
        }
    }
    
    
}
