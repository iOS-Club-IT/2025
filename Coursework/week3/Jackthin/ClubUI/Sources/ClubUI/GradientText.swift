import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
public struct GradientText: View {
    let text: String
    let colors: [Color]
    
    public init(_ text: String, colors: [Color]) {
        self.text = text
        self.colors = colors
    }
    
    public var body: some View {
        Text(text)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .mask(Text(text))
    }
}

#if DEBUG
@available(iOS 13.0, macOS 10.15, *)
struct GradientText_Previews: PreviewProvider {
    static var previews: some View {
        GradientText("Hello, Gradient!", colors: [.blue, .green])
    }
}
#endif