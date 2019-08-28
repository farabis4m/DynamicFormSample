//
//  RowExtension.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/13/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

extension Row {
    open func validateRowError() {
        let rowIndex = indexPath?.row ?? 0
        while (section?.count ?? 0) > rowIndex + 1 && section?[rowIndex + 1] is ValidationRow {
            section?.remove(at: rowIndex + 1)
        }
        if !isValid, let error = validationErrors.map({ $0.msg }).first {
            let suffix: Any = tag ?? rowIndex
            let labelRow = ValidationRow(tag: "error\(suffix)")
            labelRow.title = error
            let indexPathNew = (indexPath?.row ?? 0) +  1
            section?.insert(labelRow, at: indexPathNew)
        }
    }
}
