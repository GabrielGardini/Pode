//
//  ChildViewModel.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData

@Observable
class ChildViewModel {

    func addChild(
        name: String,
        birthDate: Date,
        allergies: [String] = [],
        context: ModelContext
    ) {
        let child = Child(
            name: name,
            birthDate: birthDate,
            allergies: allergies
        )

        context.insert(child)
        print("Saved child: \(child.name), \(child.age), \(child.allergies)")
    }

    func removeChild(_ child: Child, context: ModelContext) {
        context.delete(child)
        print("Deleted child: \(child.name)")
    }

    func editChild(
        _ child: Child,
        name: String,
        birthDate: Date,
        allergies: [String] = []
    ) {
        child.name = name
        child.birthDate = birthDate
        child.allergies = allergies
        
        print("Edited child: \(child.name)")
    }
}
