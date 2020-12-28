//
//  Validators.swift
//
//  Created by Evghenii Todorov.
//

import Foundation

protocol Validation {
    func setValidStyle()
    func setErrorStyle(message: String?)
    var value: String? { get }
    var label: String { get }
}

class ValidatorRule {
    typealias RuleType = (String?) -> Bool
    
    let rule: RuleType
    var message: String?
    
    init(rule: @escaping RuleType) {
        self.rule = rule
    }
    
    func test(value: String?) -> Bool {
        return rule(value)
    }
}

class EmptyRule: ValidatorRule {
    
    required init(message: String?) {
        super.init { value -> Bool in
            guard let value = value else { return false }
            return !value.isEmpty
        }
        
        self.message = message
    }
}

class MinimumCharactersRule: ValidatorRule {
    
    required init(minimumLength: Int, message: String?) {
        super.init { value -> Bool in
            guard let value = value else { return false }
            return value.characters.count >= minimumLength
        }
        
        self.message = message
    }
}

class DigitCharactersRule: ValidatorRule {
    
    required init(message: String?) {
        super.init { value -> Bool in
            guard let value = value else { return false }
            let characterSet = CharacterSet(charactersIn: "0123456789").inverted
            return value.rangeOfCharacter(from: characterSet) == nil
        }
        
        self.message = message
    }
}

class PhoneNumberRule: ValidatorRule {
    
    required init(message: String?) {
        super.init { value -> Bool in
            guard let value = value else { return false }
            let characterSet = CharacterSet(charactersIn: "0123456789+ .()-*#").inverted
            return value.rangeOfCharacter(from: characterSet) == nil
        }
        
        self.message = message
    }
}

class PositiveNumberRule: ValidatorRule {
    
    required init(message: String?) {
        super.init { value -> Bool in
            guard let value = value else { return false }
            guard let doubleValue = Double(value), doubleValue > 0 else { return false }
            
            return true
        }
        
        self.message = message
    }
}

class Validator {
    
    private let subject: Validation
    private var rules: [ValidatorRule]
    
    init(subject: Validation) {
        self.subject = subject
        self.rules = []
    }
    
    var validValue: String? {
        let value = subject.value
        
        for rule in rules {
            if rule.test(value: value) == false {
                subject.setErrorStyle(message: rule.message)
                return nil
            }
        }
        
        subject.setValidStyle()
        return value
    }
    
    func addRule(_ rule: ValidatorRule) {
        rules.append(rule)
    }
}

class EmptyValueValidator: Validator {
    
    override init(subject: Validation) {
        super.init(subject: subject)

        addRule(EmptyRule(message: "Empty subject"))
    }
    
}

class PasswordValidator: EmptyValueValidator {
    
    required init(subject: Validation, minLength: Int) {
        super.init(subject: subject)
        
        addRule(MinimumCharactersRule(minimumLength: minLength, message: "Minimum \(minLength) characters."))
    }
    
}

class MobileValidator: EmptyValueValidator {
    
    override init(subject: Validation) {
        super.init(subject: subject)
        
        addRule(PhoneNumberRule(message: "Wrong phone number"))
    }
    
}

class CodeValidator: EmptyValueValidator {
    
    required init(subject: Validation, minLength: Int) {
        super.init(subject: subject)

        addRule(MinimumCharactersRule(minimumLength: minLength, message: "Minimum \(minLength) characters."))
        addRule(DigitCharactersRule(message: "Please digits only"))
    }
}

class AmountValidator: EmptyValueValidator {
    
    override init(subject: Validation) {
        super.init(subject: subject)

        addRule(PositiveNumberRule(message : "Please positive digits only"))
    }

}
