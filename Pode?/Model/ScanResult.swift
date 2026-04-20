//
//  ScanResult.swift
//  Pode?
//
//  Created by Marlon Ribas on 20/04/26.
//

import SwiftUI

struct ScanResult: Identifiable, Equatable {
    var id = UUID()
    var image: UIImage?
    var description: String
    
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        lhs.description == rhs.description &&
        lhs.image == rhs.image
    }
}
