//
//  ScannerView.swift
//  Pode?
//
//  Created by Marlon Ribas on 18/04/26.
//

import SwiftUI

struct ScanResult {
    var image: UIImage
    var description: String = ""
}

struct ScannerView: View {
    
    @State private var result: ScanResult?
    
    var body: some View {
        CameraTest()
    }
    
}
