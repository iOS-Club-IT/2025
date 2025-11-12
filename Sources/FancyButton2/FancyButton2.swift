import SwiftUI

public struct FancyButton: View {
    public let title: String
    public let action: () -> Void
    @State private var isPressed = false

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                    action()
                }
            }
        }) {
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
                .scaleEffect(isPressed ? 0.95 : 1)
                .buttonStyle(PlainButtonStyle())
        }
    }
}
