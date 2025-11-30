import SwiftUI

struct SudokuCellView: View {
    @Binding var text: String
    var isSolved: Bool
    
    var body: some View {
        TextField("", text: $text)
            .multilineTextAlignment(.center)
            .font(.system(size: 20, weight: isSolved ? .bold : .regular))
            .foregroundColor(isSolved ? Color(red: 0x55/255.0, green: 0xAA/255.0, blue: 0x00/255.0) : .black)
            .frame(width: 35, height: 35) // Adjusted size for iOS screen
            .background(isSolved ? Color(red: 0xCC/255.0, green: 0xFF/255.0, blue: 0x99/255.0) : Color.white)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0), lineWidth: 1)
            )
            .keyboardType(.numberPad)
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
                if !newValue.allSatisfy({ $0.isNumber }) {
                    text = ""
                }
            }
    }
}
