//
//  ScannerFlowView.swift
//  Pode?
//
//  Created by Marlon Ribas on 19/04/26.
//

import SwiftUI

enum Route: Hashable {
    case preview
    case description
}

struct ScannerFlowView: View {
    
    @Binding var result: ScanResult
    let onFinish: (ScanResult) -> Void
    
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            
            ScannerView(result: $result) {
                path.append(.preview)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                    
                case .preview:
                    PhotoPreviewView(
                        result: $result,
                        onNext: {
                            path.append(.description)
                        },
                        onRetake: {
                            path.removeLast()
                        }
                    )
                    
                case .description:
                    DescriptionView(
                        result: $result,
                        onComplete: {
                            onFinish(result)
                        }
                    )
                }
            }
        }
    }
}
