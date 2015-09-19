//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Zhou Lin on 15-8-6.
//  Copyright (c) 2015年 Zhou Lin. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable{
        case Operand(Double)
        case UnaryOperation(String, Double->Double)
        case BinaryOperation(String, (Double,Double)->Double)
        case ConstPI(Double)
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .ConstPI(let number):
                    return "\(number)"
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knowOps = [String: Op]()
    
    private var variableValues = [String: Double]()
    
    init(){
        
        func learnOp(op: Op) {
            knowOps[op.description] = op
        }
        
        knowOps["×"] = Op.BinaryOperation("×",*)
        knowOps["÷"] = Op.BinaryOperation("÷"){ $1 / $0 }
        knowOps["+"] = Op.BinaryOperation("+",+)
        knowOps["-"] = Op.BinaryOperation("-"){ $1 - $0 }
        knowOps["√"] = Op.UnaryOperation("√", sqrt)
        knowOps["Sin"] = Op.UnaryOperation("Sin", sin)
        knowOps["Cos"] = Op.UnaryOperation("Cos", cos)
        knowOps["PI"] = Op.ConstPI(M_PI)
        
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {// guaranteed to be a PropertyList
        get{
            return opStack.map { $0.description }
            
        }
        set{
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op=knowOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
    
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1,operand2), op2Evaluation.remainingOps)
                    }
                }
            case .ConstPI(let number):
                return (M_PI , remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func clear() {
        opStack.removeAll(keepCapacity: false)
    }
    
    
    func pushOperand(operand: Double) ->Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knowOps [symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}