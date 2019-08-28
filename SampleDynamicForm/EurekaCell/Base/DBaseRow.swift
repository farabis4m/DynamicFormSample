//
//  DBaseRow.swift
//  SampleDynamicForm
//
//  Created by Jafar khan on 6/12/19.
//  Copyright © 2019 Farabi Technology Middle East. All rights reserved.
//

import Foundation
import Eureka

//Since RowType can only be added for final class, discarding inheritance from RowType and cannot include rowValidation in init()
class DBaseRow: BaseFieldRow<DBaseCell> {
	
	var callbackOnRowFocusChanged: (() -> Void)?
	required init(tag: String?) {
		super.init(tag: tag)
	}
    
    var tapAction: VoidClosure?

    var values = [Listable]()

    func addValidation(params: [[String: Any]]) {
            params.forEach { (dict) in
                if (dict["rule"] as? String) == Rule.required.rawValue {
                    add(rule: RuleRequired(msg: (dict[Rule.required.message] as? String) ?? "", id: nil))
                }
                else if (dict["rule"] as? String) == Rule.regex.rawValue {
                    add(rule: RuleRegExp(regExpr: (dict[Rule.regex.value] as? String) ?? "", allowsEmpty: true, msg: (dict[Rule.regex.message] as? String) ?? "", id: nil))
                }
                else if (dict["rule"] as? String) == Rule.dateFormat.rawValue {
                    let dateFomat = dict[Rule.dateFormat.value] as? String ?? ""
                    addDateFormat(format:dateFomat)
                }
            }
    }
    
    func createListableValues(arrayValues:[[String:String]]) {
        arrayValues.forEach { [weak self] (value) in
            let dLov = DLOV()
            dLov.code = (value["code"]) ?? ""
            dLov.listName = (value["desc"]) ?? ""
            self?.values.append(dLov)
        }
    }
    
	func clear() {
		value = nil
        updateCell()
	}
    
    private func addDateFormat(format: String) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        formatter = dateFormat
    }
	
	@discardableResult
	public func onFocusChanged(_ callback: @escaping (_ cell: Cell, _ row: DBaseRow) -> Void) -> DBaseRow {
		callbackOnRowFocusChanged = { [unowned self] in callback(self.cell, self) }
		return self
	}
}



class DBaseCell: BasicFieldTableViewCell<String> { }

