//
//  BaseDynamicFormViewController.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/19/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

class BaseDynamicFormViewController: FormViewController {
    
    func initializeForm(dict: [String: Any]) {
        var tags: [String] = []
        if let dynamicList = dict["dynamicForm"] as? [[String:Any]] {
            let section = Section()
            for obj in dynamicList {
                
                if let row = getFormRowByType(params: obj) {
                    section <<< row
                    
                }
            }
            form += [section]
        }
        
        if let documentList = dict["documents"] as? [[String: Any]] {
            let section = Section("Upload Documents")
            for obj in documentList {
                if let row = getFormRowByType(params: obj) {
                    section <<< row
                }
            }
            form += [section]
        }
        
        guard let arrayRelation = dict["relations"] as? [[String:Any]] else { return }
        
        //Getting the whole relation controls and hiding initially
        let arrayOfValues = arrayRelation.compactMap { $0["related_list"] } as? [[String]]
        if let arrayRelatedList = arrayOfValues?.flatMap({ $0 })  {
            form.hideRows(arrayTags: arrayRelatedList)
        }
        
        //Handling the relation
        manageRelation(arrayRelation: arrayRelation)
    }
    
    func getFormRowByType(params: [String: Any]) -> BaseRow? {
        return nil
    }
    
    func getTagForRow(params: [String: Any]) -> String {
        let tag = params["tag"] as? String ?? ""
        return tag
    }
    
}

private extension BaseDynamicFormViewController {
    
    func manageRelation(arrayRelation: [[String:Any]]) {
        arrayRelation.forEach({ (dict) in
            let control = dict["Control"] as? String ?? ""
            if let conditionDict = dict["values"] as? [[String:Any]] {
                conditionDict.forEach({ (condition) in
                    let conditionValue = condition["code"] as? String ?? ""
                    if let relatedControl = condition["related_controls"] as? [[String:String]] {
                        let arrayControl = relatedControl.compactMap { $0["Control"] }
                        hideRowsByConditions(tags: arrayControl, relatedControlTag: control, conditionValue: conditionValue)
                    }
                })
            }
            
        })
    }
    
    func hideRowsByConditions(tags: [String], relatedControlTag: String, conditionValue: String) {
        tags.forEach({ [weak self] (tagControl) in
            let rowConditionControl = self?.form.rowBy(tag: tagControl)
            rowConditionControl?.hidden = Condition.function([relatedControlTag], { form in
                let questionRow = form.rowBy(tag: relatedControlTag) as? DPickerRow
                let value = questionRow?.values.filter { $0.desc == questionRow?.value }
                return !(value?.first?.code == conditionValue)
            })
        })
    }
}

enum DFormComponent: String {
    case controlEditText = "control_EditText"
    case controlCheckBox = "control_CheckBox"
    case controlSearchText = "control_AutoCompleteTextView"
    case controlLabelRow = "control_Label"
    case controlDatePickerRow = "control_Calendar"
    case controlSwitchRow = "control_Switch"
    case controlPicker = "control_Picker"
    case controlButton = "control_Button"
    case controlImage = "control_image"
    case controlDocument = "control_Document"
}


