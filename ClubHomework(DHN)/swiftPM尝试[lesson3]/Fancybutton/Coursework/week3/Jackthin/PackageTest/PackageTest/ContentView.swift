//
//  ContentView.swift
//  PackageTest
//
//  Created by Jackthin Shin on 2025/11/7.
//

import SwiftUI
import ClubUI

struct ContentView: View {
    var body: some View {
        VStack {
            FancyButton("Press Me") { print("Tapped!") }
            GradientText("Hello ClubUI!", colors: [.purple, .blue])
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
