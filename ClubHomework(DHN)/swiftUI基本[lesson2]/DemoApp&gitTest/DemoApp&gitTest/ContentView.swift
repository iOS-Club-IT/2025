//
//  ContentView.swift
//  DemoApp&gitTest
//
//  Created by 刁泓宁 on 2025/10/13.
//

import SwiftUI
import Fancybutton

//主视图
struct ContentView: View{
    var body: some View{
        TextImageExample()
        ControlsExample()
        NavigationListExample()
        PackageTestView()
    }
}
    //文本与图片视图
    struct TextImageExample: View{
        var body: some View{
            VStack(alignment: .leading , spacing: 20){
                Text("Hello,iOS club!")
                    .font(.system(size:40))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue,.purple,.pink],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                Image(systemName: "apple.intelligence")
                    .font(.system(size:40))
                    .symbolRenderingMode(.multicolor)
            }
            .padding()
        }
    }
    //控件示例视图
    struct ControlsExample: View{
        @State private var isDark = false
        @State private var name = ""
        @State private var count = 0
        var body: some View{
            VStack{
                TextField("Enter your name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button("Press me"){
                    count += 1
                }
                .buttonStyle(.borderedProminent)
                Text("Button pressed \(count) times")
                Toggle("Night Mode", isOn: $isDark)
            }
            .padding()
            .background(isDark ? Color.black : Color.white)
            .foregroundColor(isDark ? Color.white : Color.black)
        }
    }
    //导航与列表视图
    struct NavigationListExample: View{
        var body: some View{
            NavigationView{
                List{
                    NavigationLink("Home", destination: Text("Welcome to Home"))
                    NavigationLink("Profile", destination: Text("This is your profile"))
                    NavigationLink("Settings", destination: Text("Adjust your settings here"))
                }
                .navigationTitle("Menu")
            }
        }
    }
    //包功能测试
    struct PackageTestView: View{
        var body: some View{
            VStack{
                FancyButton("Tap Me"){
                    print("Fancy Button tapped!")
                }
                .padding()
            }
        }
    }
    
    
    //基本动画
#Preview {
    ContentView()
}

