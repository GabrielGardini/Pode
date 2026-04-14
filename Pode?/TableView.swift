//
//  TableView.swift
//  Pode?
//
//  Created by Marlon Ribas on 14/04/26.
//

import SwiftUI

struct TableView: View {
    
    let table: ParsedTable
    
    var body: some View {
        let columnCount = table.headers?.count ?? table.rows.first?.count ?? 1
        
        // Cria colunas dinâmicas
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
        
        LazyVGrid(columns: columns, spacing: 8) {
            
            // MARK: - Headers
            if let headers = table.headers {
                ForEach(headers.indices, id: \.self) { index in
                    Text(headers[index])
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
            }
            
            // MARK: - Rows
            ForEach(table.rows.indices, id: \.self) { rowIndex in
                let row = table.rows[rowIndex]
                
                ForEach(row.indices, id: \.self) { colIndex in
                    Text(row[colIndex])
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
    }
}
