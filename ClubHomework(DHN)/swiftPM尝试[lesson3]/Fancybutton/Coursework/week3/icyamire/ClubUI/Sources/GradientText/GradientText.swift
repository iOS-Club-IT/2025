import SwiftUI

// 同样声明为 public
public struct GradientText: View {
    
    // MARK: - 属性
    
    private let text: String
    private let colors: [Color]
    private let font: Font
    
    // MARK: - 初始化
    
    public init(
        _ text: String,
        colors: [Color],
        font: Font = .largeTitle.bold() // 提供默认字体
    ) {
        self.text = text
        self.colors = colors
        self.font = font
    }
    
    // MARK: - 视图主体
    
    public var body: some View {
        Text(text)
            .font(font)
            // 使用 .foregroundStyle (iOS 15+) 来应用渐变
            // 这是现代 SwiftUI 中最高效的做法
            .foregroundStyle(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

// MARK: - 预览
struct GradientText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            GradientText("Hello ClubUI!", colors: [.purple, .blue])
            
            GradientText(
                "Another Style",
                colors: [.green, .yellow, .orange],
                font: .system(size: 40, weight: .thin, design: .serif)
            )
        }
    }
}