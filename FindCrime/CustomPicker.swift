//
//  CustomPicker.swift
//  FindCrime
//
//  Created by 박미정 on 6/14/25.
//

import SwiftUI

struct CustomPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Picker(selection: $selection, label: Text("")) {
                ForEach(options, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
