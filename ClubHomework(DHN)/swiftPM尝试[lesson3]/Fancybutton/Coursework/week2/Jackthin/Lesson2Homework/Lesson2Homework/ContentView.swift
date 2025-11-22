//
//  ContentView.swift
//  Lesson2Homework
//
//  Created by Jackthin Shin on 2025/10/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            List{
                HStack(spacing: 30){
                    Spacer()
                    Image("Image")
                        .resizable()
                        .frame(width:120, height:120)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    Image("Avatar")
                        .resizable()
                        .frame(width:120, height:120)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    Spacer()
                }
                .padding()
                NavigationLink("Clicking Counts", destination: ClickView())
                NavigationLink("H V Z Stacks Demo", destination: StacksView())
                NavigationLink("Text Modifier", destination: ModifierView())
                NavigationLink("About Us", destination: AboutView())
            }
            .navigationTitle("Lesson 2 Homework")
//            从网站上学习到的toolbar
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel", systemImage: "xmark") {}
//                }
//
//                ToolbarItemGroup(placement: .primaryAction) {
//                    Button("Draw", systemImage: "pencil") {}
//                    Button("Erase", systemImage: "eraser") {}
//                }
//
//                ToolbarSpacer(.flexible)
//
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save", systemImage: "checkmark") {}
//                }
//            }
        }
    }
}

struct ClickView: View {
    @State private var name = ""
    @State private var count = 0
    var body: some View {
        VStack(spacing: 20){
            Image(systemName: "hand.point.up.left.fill")
                .font(.largeTitle)
            Text("Clicking Counts")
                .font(.largeTitle)
            Text("Hey there! \(name)\nYou've already clicked for \(count) times")
                .font(.headline)
            TextField("Please Enter Your Name Here:", text: $name)
                .textFieldStyle(.roundedBorder)
            HStack{
                Button("Reset") {
                    count = 0
                }
                .buttonStyle(.glass)
                Button("Click") {
                    count += 1
                }
                .buttonStyle(.glassProminent)
            }
        }
        .padding()
    }
}

struct StacksView: View {
    var rect: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.brown)
            .stroke(Color.black, lineWidth: 4)
            .frame(width: 100, height: 100)
    }
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text("·HStack")
                    .font(.largeTitle)
                HStack {
                    Spacer()
                    rect
                    rect
                    rect
                    Spacer()
                }
            }
            .padding()
            Divider()
            HStack {
                Spacer()
                Text("·VStack")
                    .font(.largeTitle)
                Spacer()
                VStack {
                    rect
                    rect
                    rect
                }
                Spacer()
            }
            .padding()
            Divider()
            HStack {
                Spacer()
                Text("·ZStack")
                    .font(.largeTitle)
                Spacer()
                ZStack {
                    rect
                    rect
                    rect
                }
                Spacer()
            }
            .padding()
        }
        .padding()
    }
}

struct ModifierView: View {
    @State private var TextSha = true
    @State private var BackColor = true
    @State private var BackSha = true
    var body: some View {
        List{
            Text(" Modified Text ")
                .font(.largeTitle)
                .shadow(radius: TextSha ? 5 : 0)
                .padding()
                .background(BackColor ? Color.brown : Color.white)
                .cornerRadius(12)
                .shadow(radius: BackSha ? 5 : 0)
            Toggle("Text Shadow", isOn: $TextSha)
            Toggle("Background Color", isOn: $BackColor)
            Toggle("Background Shadow", isOn: $BackSha)
        }
    }
}

struct AboutView: View {
    var body: some View {
        Spacer()
        Image("Image")
            .resizable()
            .frame(width:120, height:120)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .gray, radius: 5, x: 0, y: 5)
        Text("iOS Club")
            .font(.title)
        Text("QQ Group: 860518540")
        Spacer()
        Text("我们是热爱苹果开发的社团！")
        Text("Apple Development")
        Spacer()
        Divider()
        Spacer()
        Image("Avatar")
            .resizable()
            .frame(width:120, height:120)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .gray, radius: 5, x: 0, y: 5)
        Text("Jackthin Shin")
            .font(.title)
        Spacer()
    }
}

#Preview {
    ContentView()
//    ClickView()
//    StacksView()
//    ModifierView()
//    AboutView()
}
