import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SudokuViewModel()
    @State private var selectedDifficulty: Difficulty = .easy
    
    var body: some View {
        ZStack {
            Color(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("Sudoku")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(Color(red: 0xDD/255.0, green: 0xDD/255.0, blue: 0xDD/255.0))
                    .padding(.top, 20)
                
                // Grid
                VStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { br in
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { bc in
                                BlockView(viewModel: viewModel, br: br, bc: bc)
                            }
                        }
                    }
                }
                .padding(5)
                // .background(Color(red: 0xDD/255.0, green: 0xDD/255.0, blue: 0xDD/255.0)) // Background for spacing gaps
                // Actually Python app uses block_frame background #DDDDDD
                
                // Info Panel
                Text(viewModel.message)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0xCC/255.0, green: 0xEE/255.0, blue: 0xFF/255.0))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(red: 0xAA/255.0, green: 0xAA/255.0, blue: 0xAA/255.0), lineWidth: 3)
                    )
                    .foregroundColor(.black)
                    .padding(.horizontal)
                
                // Buttons
                VStack(spacing: 15) {
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)

                    HStack(spacing: 15) {
                        Button(action: {
                            viewModel.loadGame(difficulty: selectedDifficulty)
                        }) {
                            Text("Load Game")
                                .modifier(ButtonStyle())
                        }
                        
                        Button(action: {
                            viewModel.solve()
                            hideKeyboard()
                        }) {
                            Text("Solve Now")
                                .modifier(ButtonStyle())
                        }
                        
                        Button(action: {
                            viewModel.clear()
                        }) {
                            Text("Clear")
                                .modifier(ButtonStyle())
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }

        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct BlockView: View {
    @ObservedObject var viewModel: SudokuViewModel
    let br: Int
    let bc: Int
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { j in
                        let r = br * 3 + i
                        let c = bc * 3 + j
                        SudokuCellView(
                            text: $viewModel.board[r][c],
                            isSolved: viewModel.solvedIndices.contains("\(r),\(c)")
                        )
                    }
                }
            }
        }
        .padding(4)
        .background(Color(red: 0xDD/255.0, green: 0xDD/255.0, blue: 0xDD/255.0))
        .cornerRadius(5)
    }
}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .bold))
            .padding(10)
            .background(Color(red: 0xDD/255.0, green: 0xDD/255.0, blue: 0xDD/255.0))
            .foregroundColor(.black)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(red: 0xAA/255.0, green: 0xAA/255.0, blue: 0xAA/255.0), lineWidth: 3)
            )
    }
}
