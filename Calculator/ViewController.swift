//
//  ViewController.swift
//  Calculator
//
//  Created by Zhou Lin on 15-8-5.
//  Copyright (c) 2015年 Zhou Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }

    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        brain.clear()
        displayValue = 0
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let tempResult = displayValue {
            if let result = brain.pushOperand(displayValue!){
                displayValue = result
            }else {
                displayValue = 0
            }
        }else {
            brain.clear()
        }
    }
    
    var displayValue: Double? {
        get{
            if let formatter = NSNumberFormatter().numberFromString(display.text!) {
                return formatter.doubleValue
            }else {
                display.text = "Error!"
                return nil;
            }
        }
        set{
            userIsInTheMiddleOfTypingANumber = false
            display.text = "\(newValue!)"
        }
    }
}

