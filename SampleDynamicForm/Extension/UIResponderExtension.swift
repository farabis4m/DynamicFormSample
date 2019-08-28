//
//  UIResponderExtension.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/11/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import UIKit

extension UIResponder {
    public static var identifier: String {
        return "\(self)"
    }
    
    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
