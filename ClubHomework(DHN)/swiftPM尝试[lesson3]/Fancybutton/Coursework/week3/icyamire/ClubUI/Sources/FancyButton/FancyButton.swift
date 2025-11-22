import SwiftUI

// 必须声明为 public，这样才能在 App 中访问
public struct FancyButton: View {
    
    // MARK: - 属性
    
    private let title: String
    private let colors: [Color]
    private let cornerRadius: CGFloat
    private let action: () -> Void
    
    // MARK: - 初始化
    
    // 必须有 public 的 init
    public init(
        _ title: String,
        colors: [Color] = [.blue, .purple], // 提供默认渐变色
        cornerRadius: CGFloat = 10.0,      // 提供默认圆角
        action: @escaping () -> Void
    ) {
        self.title = title
        self.colors = colors
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    // MARK: - 视图主体
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity) // 让按钮宽度自适应
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: colors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(cornerRadius)
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3) // 增加一点阴影
        }
    }
}

// MARK: - 预览 (可选但推荐)
// 我们可以直接在包里预览组件效果
struct FancyButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FancyButton("Tap Me!") {
                print("Button tapped!")
            }
            
            FancyButton(
                "Customized",
                colors: [.orange, .red],
                cornerRadius: 20
            ) {
                print("Custom button tapped!")
            }
        }
        .padding()
    }
}