//
//  HomeViewModel.swift
//  MyTenTenEducation
//
//  Created by Aymen Rebouh on 2018/04/18.
//  Copyright © 2018 Aymen Rebouh. All rights reserved.
//

import Foundation

struct HomeViewModel {
    
    // MARK: Properties
    
    var instructions: [Instruction] = []
    var functions: [String: [Instruction]] = [:]
    var isCurrentlyInsideFunction = (false, "")
    
    // MARK: Core

    mutating func execute(someInstructions: [Instruction]) throws {
        var numbers: [Int] = []
        var instructionsToExecute = someInstructions
        
        // WHile there are instructions
        while !instructionsToExecute.isEmpty {
            if let instruction = instructionsToExecute.last {
                instructionsToExecute = Array(instructionsToExecute.dropLast())
                switch instruction {
                case .print:
                    if isCurrentlyInsideFunction.0 {
                        functions[isCurrentlyInsideFunction.1]?.insert(instruction, at: 0)
                    } else {
                        if let number = numbers.last {
                            numbers = Array(numbers.dropLast())
                            print(number)
                        } else {
                            throw SimulatorError.custom("cannot print a value because 0 numbers")
                        }
                    }
                case .ret:
                    isCurrentlyInsideFunction = (false, "")
                case .push(let val):
                    if isCurrentlyInsideFunction.0 {
                        functions[isCurrentlyInsideFunction.1]?.insert(instruction, at: 0)
                    } else {
                        numbers.append(val)
                    }
                case .mult:
                    if isCurrentlyInsideFunction.0 {
                        functions[isCurrentlyInsideFunction.1]?.insert(instruction, at: 0)
                    } else {
                        if let firstNumber = numbers.last {
                            numbers = Array(numbers.dropLast())
                            if let secondNumber = numbers.last {
                                numbers = Array(numbers.dropLast())
                                numbers.append(firstNumber * secondNumber)
                            } else {
                                throw SimulatorError.custom("cannot mult a value because only 1 numbers")
                            }
                        } else {
                            throw SimulatorError.custom("cannot mult a value because 0 numbers")
                        }
                    }
                    
                case .call(let functionName):
                    if let functionInstructions = functions[functionName] {
                        instructionsToExecute.append(contentsOf: functionInstructions)
                    }
                case .function(let functionName):
                    functions[functionName] = []
                    isCurrentlyInsideFunction = (true, functionName)
                default: break
                }
            }
        }
    }
}
