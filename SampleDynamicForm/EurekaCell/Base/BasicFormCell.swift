//
//  BasicFormCell.swift
//  SampleDynamicForm
//
//  Created by Jafar khan on 6/16/19.
//  Copyright © 2019 Farabi Technology Middle East. All rights reserved.
//

import Foundation
import Eureka

class BasicFormCell<T>: Cell<T>, CellType  where T: Equatable {
	
	override func update() {
		super.update()
		textLabel?.text = nil
	}
}
