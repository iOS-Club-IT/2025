// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
public struct FancyButton: View {
    private var title: String
    private var action: () -> Void
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
        .buttonStyle(.plain)
    }
}

// Simple preview for Xcode canvas
@available(iOS 13.0, macOS 10.15, *)
struct FancyButton_Previews: PreviewProvider {
    static var previews: some View {
        FancyButton("Tap Me") {
            print("Button tapped!")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
