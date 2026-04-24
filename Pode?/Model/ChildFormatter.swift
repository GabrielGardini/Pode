//
//  ChildFormatter.swift
//  Pode?
//
//  Created by Marlon Ribas on 17/04/26.
//


struct ChildFormatter {
    
    static func format(_ children: [Child]) -> String {
        
        let parts = children.map { child in
            let name = child.name
            let age = "\(child.age) meses"
            
            return "{ name: \"\(name)\", age: \"\(age)\" }"
        }
        
        return "[\n  \(parts.joined(separator: ",\n  "))\n]"
    }
}
