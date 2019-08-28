//
//  BasicFieldTableViewCell.swift
//  SampleDynamicForm
//
//  Created by Jafar khan on 6/16/19.
//  Copyright © 2019 Farabi Technology Middle East. All rights reserved.
//

import Foundation
import Eureka

class BasicFieldTableViewCell<T> : BasicFormCell<T>, UITextFieldDelegate, TextInputCell where T: Equatable, T: InputTypeInitiable {
	
	// TextInput protocol
	var textInput: UITextInput { return textField ?? UITextField() }
	
	@IBOutlet weak var textField: UITextField?
	@IBOutlet weak var titleLabel: UILabel?
	
	public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil) { [weak self] _ in
			self?.setNeedsUpdateConstraints()
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	// remove all notifications
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	open override func setup() {
		super.setup()
		backgroundColor = UIColor.clear
		textField?.addTarget(self, action: #selector(BasicFieldTableViewCell.textFieldDidChange(_:)), for: .editingChanged)
	}
	
	open override func update() {
		super.update()
		
		guard let row = row as? DBaseRow else { return }
		
		titleLabel?.text = row.titleText
		textField?.delegate = self
		textField?.text = row.displayValueFor?(row.value)
		textField?.isEnabled = row.isEnabled
		textField?.placeholder = row.placeholder
		textField?.accessibilityIdentifier = row.tag
		
		textField?.isSecureTextEntry = row.isSecureEntry
		textField?.keyboardType = row.keyboardType
        
        
	}
	
	//  returns true if cell can become first responder
	open override func cellCanBecomeFirstResponder() -> Bool {
		return !row.isDisabled && textField?.canBecomeFirstResponder ?? false
	}
	
	// Returns true if cell can become first responder in a given direction
	open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
		return textField?.becomeFirstResponder() ?? false
	}
	
	
	// resign first responder
	open override func cellResignFirstResponder() -> Bool {
		return textField?.resignFirstResponder() ?? false
	}
	
	// formatting after text field text change
	@objc open func textFieldDidChange(_ textField: UITextField) {
		
		guard let textValue = textField.text else {
			row.value = nil
			return
		}
		guard let fieldRow = row as? FieldRowConformance, let _ = fieldRow.formatter else {
			row.value = textValue.isEmpty ? nil : (T.init(string: textValue) ?? row.value)
			return
		}
	}
	
	// use the formatter to create the string to display
	private func displayValue(useFormatter: Bool) -> String? {
		guard let value = row.value else { return nil }
		if let formatter = (row as? FormatterConformance)?.formatter, useFormatter {
			return (textField?.isFirstResponder ?? false) ? formatter.editingString(for: value) : formatter.string(for: value)
		}
		return String(describing: value)
	}
	
	//  modify the text after user begins to type
	open func textFieldDidBeginEditing(_ textField: UITextField) {
		
		formViewController()?.beginEditing(of: self)
		formViewController()?.textInputDidBeginEditing(textField, cell: self)
		textFieldDidChange(textField)
		
		if let fieldRowConformance = row as? FormatterConformance, fieldRowConformance.formatter != nil, fieldRowConformance.useFormatterOnDidBeginEditing ?? fieldRowConformance.useFormatterDuringInput {
			textField.text = displayValue(useFormatter: true)
		} else {
			textField.text = displayValue(useFormatter: false)
		}
	}
	
	// handle formatting after editing is done
	open func textFieldDidEndEditing(_ textField: UITextField) {
		
		textFieldDidChange(textField)
		textField.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
	
		// end editing is called after setting text to field since last input is missing in textfields which has maxLength set
		formViewController()?.endEditing(of: self)
		formViewController()?.textInputDidEndEditing(textField, cell: self)
        
        // if row field should format to currency then update textfiled
        guard let row = row as? DBaseRow else { return }
        if row.needCurrencyFormatting {
            textField.text = ""
        }
        
		if row.needsValidation { row.validate() }
		row.callbackOnRowFocusChanged?()
		
	}
	
	// retuns true if textField should return
	open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
	}
	
	open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		guard let row = row as? DBaseRow, let text = textField.text else { return true }
		
		if row.isRealTimeValidation {
			row.validate()
		}
		
		// using NSString as textField text length was not getting updated when user deletes text
		let currentString: NSString = text as NSString
		let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
		

		guard let maxLength = row.maxLength else { return true }
		
		// return false if newstring length is greater than max length
		guard newString.length <= maxLength else {
			textField.resignFirstResponder()
			return false
		}
		
		//The code inside this condition is for avoiding dot while tapping double space.
		
		//Ensure we're not at the start of the text field and we are inserting text.
		if range.location > 0 && string.count > 0 {
			
			let whitespace = CharacterSet.whitespaces
			let start = string.unicodeScalars.startIndex
			let location = text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: range.location - 1)
			
			//Check if a space follows a space
			if whitespace.contains(string.unicodeScalars[start]) && whitespace.contains(text.unicodeScalars[location]) {
				
				//Manually replace the space with your own space, programmatically
				textField.text = currentString.replacingCharacters(in: range, with: " ") as String
				
				//Tell UIKit not to insert its space, because you've just inserted your own
				guard newString.length == maxLength else {
					textFieldDidChange(textField)
					return false
				}
				
				textField.resignFirstResponder()
				return false
			}
		}
		
		// if textField text length is equal to the max length value, update the textField with the last character input and resign responder
		guard newString.length == maxLength else { return newString.length <= maxLength }
		textField.text = text + string
		textField.resignFirstResponder()
		return false
	}
	
	// returns true if textfield should begin editing
	open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
	}
	
	// returns true if textfield should clear
	open func textFieldShouldClear(_ textField: UITextField) -> Bool {
		return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
	}
	
	// returns true if textfield should end editing
	open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
	}
	
	// returns action is allowed or not
	open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		guard action == #selector(paste(_:)), let row = row as? DBaseRow else { return true }
		return !row.disableCopyPaste
	}
}
