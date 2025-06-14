//  LabeledPicker.swift
//  FindCrime
//
//  Created by 박미정 on 6/15/25.
//

import SwiftUI

struct LabeledPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Picker(selection: $selection, label: Text("")) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
