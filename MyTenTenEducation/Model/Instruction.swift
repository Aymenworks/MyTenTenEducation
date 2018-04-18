//
//  Instruction.swift
//  MyTenTenEducation
//
//  Created by Rebouh Aymen on 18/04/2018.
//  Copyright © 2018 Aymen Rebouh. All rights reserved.
//

import UIKit

enum Instruction {
    case mult
    case print
    case ret
    case push(Int)
    case call(String)
    case function(String)
    
    var textDescription: String {
        switch self {
        case .mult:
            return "mult"
        case .print:
            return "print"
        case .ret:
            return "ret"
        case .push(let val):
            return "push \(val)"
        case .call(let functionName):
            return "call \(functionName)"
        case .function(let functionName):
            return functionName
        }
    }
    
    var color: UIColor {
        switch self {
        case .mult:
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        case .print:
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        case .ret:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0.373453776, alpha: 1)
        case .push(_):
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        case .call(_):
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        case .function(_):
            return #colorLiteral(red: 0.9254901961, green: 0.7294117647, blue: 0.2745098039, alpha: 1)
        }
    }
    
    init?(fromTag tag: Int) {
        switch tag {
        case 10:
            self = .mult
        case 11:
            self = .print
        case 12:
            self = .ret
        case 14:
            self = .push(-1)
        case 15:
            self = .call("")
        case 16:
            self = .function("")
            default: return nil
        }
    }
    
    var isADeclaration: Bool {
        switch self {
        case .ret, .function(_):
            return true
        default:
            return false
        }
    }
}
