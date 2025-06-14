//
//  WindowAccessor.swift
//  FindCrime
//
//  Created by 박미정 on 6/14/25.
//

import SwiftUI

struct WindowAccessor: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            if let window = view.window {
                WindowHolder.shared.window = window
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class WindowHolder {
    static let shared = WindowHolder()
    var window: UIWindow?
}
