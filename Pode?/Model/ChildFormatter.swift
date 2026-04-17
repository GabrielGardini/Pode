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
            
            let allergies = child.allergies
                .filter { !$0.isEmpty }
            
            let allergiesText = allergies.isEmpty ? "nenhuma conhecida" : allergies.joined(separator: ", ")
            
            return "{ name: \"\(name)\", age: \"\(age)\", allergies: \"\(allergiesText)\" }"
        }
        
        return "[\n  \(parts.joined(separator: ",\n  "))\n]"
    }
}
