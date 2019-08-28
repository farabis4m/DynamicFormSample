//
//  FormExtension.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/17/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

extension Form {
    //Hiding the rows by tags
    func hideRows(arrayTags: [String]) {
        arrayTags.forEach { [weak self] (tag) in
            let row = self?.rowBy(tag: tag)
            row?.hidden = true
            row?.evaluateHidden()
        }
    }
}
