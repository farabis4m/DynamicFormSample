//
//  StringExtension.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/18/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit

extension String {
    func sizeOfText(font: UIFont?) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font : font ?? UIFont()])
    }
    
    var isASCII: Bool {
        return canBeConverted(to: String.Encoding.ascii)
    }
}
