//
//  EditChildView.swift
//  Pode?
//
//  Created by Marlon Ribas on 15/04/26.
//

import SwiftUI
import SwiftData

struct EditChildView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    let child: Child
    var viewModel: ChildViewModel
    
    var body: some View {
        Text("Vo faze")
    }
}
