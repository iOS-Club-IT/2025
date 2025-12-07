import SwiftUI
import Combine

/**
 * @struct ContentView
 * @brief The main view of the Sudoku game.
 *
 * This view assembles the game board, control area, and manages the overall game state,
 * including the timer, selected cell, and game-over condition. It adapts its layout
 * for both portrait and landscape orientations.
 */
struct ContentView: View {
    /// The currently selected difficulty.
    @State private var currentDifficulty: Difficulty = .medium
    /// The game board model, observed for changes.
    @StateObject private var gameBoard: GameBoard
    /// The currently selected cell's coordinates, `nil` if no cell is selected.
    @State private var selectedCell: (row: Int, col: Int)? = nil
    /// The current input mode of the game (`viewing` or `entering`).
    @State private var inputMode: InputMode = .viewing
    /// A flag indicating if the game is over (due to too many errors).
    @State private var isGameOver: Bool = false
    /// A flag to control the visibility of the restart confirmation alert.
    @State private var showRestartAlert: Bool = false
    /// A flag to control the visibility of the settings sheet.
    @State private var showSettings: Bool = false
    /// A flag to control the visibility of the difficulty picker sheet.
    @State private var showDifficultyPicker: Bool = false
    /// The elapsed time in seconds since the timer started.
    @State private var elapsedTime: Int = 0
    /// A flag indicating if the timer is currently running.
    @State private var isTimerRunning: Bool = false
    /// A publisher that fires every second to update the timer.
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Persisted setting for dark mode.
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    /// The current device orientation.
    @State private var orientation = UIDevice.current.orientation
    
    init() {
        _gameBoard = StateObject(wrappedValue: GameBoard(difficulty: .medium))
    }
    
    /**
     * @brief Determines if a cell is related to the selected cell.
     * @param selected The coordinates of the selected cell.
     * @param current The coordinates of the cell to check.
     * @return `true` if the current cell is in the same row, column, or 3x3 subgrid as the selected cell.
     *
     * Related cells are highlighted in the UI.
     */
    private func isRelated(to selected: (row: Int, col: Int)?, at current: (row: Int, col: Int)) -> Bool {
        guard let selected = selected else { return false }
        guard selected != current else { return false }
        
        if selected.row == current.row || selected.col == current.col {
            return true
        }
        
        let selectedSubgrid = (row: selected.row / 3, col: selected.col / 3)
        let currentSubgrid = (row: current.row / 3, col: current.col / 3)
        
        return selectedSubgrid == currentSubgrid
    }
    
    /**
     * @brief Resets the entire game state to its initial values with a new difficulty.
     * @param newDifficulty The new difficulty to apply.
     */
    private func restartGame(with newDifficulty: Difficulty) {
        self.currentDifficulty = newDifficulty
        
        // Call the new update method on the existing gameBoard instance
        gameBoard.update(difficulty: newDifficulty)
        
        // Reset the view-specific state
        selectedCell = nil
        elapsedTime = 0
        isTimerRunning = false
        inputMode = .viewing
        isGameOver = false
    }
    // MARK: - ContentView
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad-specific layouts
                switch orientation {
                case .landscapeLeft, .landscapeRight:
                    iPadLandscapeLayout
                default:
                    iPadPortraitLayout
                }
            } else {
                // iPhone-specific layouts
                switch orientation {
                case .landscapeLeft:
                    landscapeLeftLayout
                case .landscapeRight:
                    landscapeRightLayout
                default:
                    portraitLayout
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            // Update orientation, but ignore unknown orientations
            if UIDevice.current.orientation.isValidInterfaceOrientation {
                self.orientation = UIDevice.current.orientation
            }
        }
        .background(Color(UIColor.systemGray6))
        .onReceive(timer) { _ in
            if isTimerRunning {
                elapsedTime += 1
            }
        }
        .onChange(of: inputMode) { _, newInputMode in
            if !isGameOver {
                isTimerRunning = (newInputMode == .entering)
            }
        }
        .onChange(of: gameBoard.errorCount) { _, newCount in
            if newCount >= gameBoard.maxErrors {
                isTimerRunning = false
                isGameOver = true
            }
        }
        .alert("游戏失败", isPresented: $isGameOver) {
            Button("重新开始") { restartGame(with: currentDifficulty) }
            Button("确定", role: .cancel) { }
        } message: {
            Text("您已达到最大错误次数。")
        }
        .alert("重新开始游戏？", isPresented: $showRestartAlert) {
            Button("重新开始", role: .destructive) { restartGame(with: currentDifficulty) }
            Button("取消", role: .cancel) { }
        } message: {
            Text("所有游戏进度都将丢失。")
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isDarkMode: $isDarkMode)
        }
        .sheet(isPresented: $showDifficultyPicker) {
            DifficultySelectionView(
                currentDifficulty: $currentDifficulty,
                restartAction: restartGame
            )
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .environmentObject(gameBoard)
    }
    /// The view layout for iPad in portrait orientation.
    private var iPadPortraitLayout: some View {
        VStack(spacing: 40) {
            HeaderView(
                showSettings: $showSettings,
                showDifficultyPicker: $showDifficultyPicker,
                currentDifficulty: currentDifficulty
            )
            .padding(.top, 40)

            GameBoardView(
                gameBoard: gameBoard,
                selectedCell: $selectedCell,
                isRelated: isRelated,
                isDarkMode: isDarkMode
            )
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .glassEffect(.regular.tint(.clear).interactive(), in: .rect(cornerRadius: 20))
            .padding(.horizontal, 80) // Increased padding for iPad portrait

            ControlAreaView(
                gameBoard: gameBoard,
                inputMode: $inputMode,
                selectedCell: $selectedCell,
                scale: nil,
                elapsedTime: elapsedTime,
                restartAction: { showRestartAlert = true }
            )

            Spacer()
        }
        .padding(.vertical)
        .edgesIgnoringSafeArea(.bottom)
    }

    /// The view layout for iPad in landscape orientation.
    private var iPadLandscapeLayout: some View {
        HStack(spacing: 20) {
            // Left side: Game Board
            VStack {
                Spacer()
                GameBoardView(
                    gameBoard: gameBoard,
                    selectedCell: $selectedCell,
                    isRelated: isRelated,
                    isDarkMode: isDarkMode
                )
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .glassEffect(.regular.tint(.clear).interactive(), in: .rect(cornerRadius: 20))
                .padding(30) // Generous padding for iPad
                Spacer()
            }

            // Right side: Controls
            VStack(spacing: 30) {
                HeaderView(
                    showSettings: $showSettings,
                    showDifficultyPicker: $showDifficultyPicker,
                    currentDifficulty: currentDifficulty
                )

                ControlAreaView(
                    gameBoard: gameBoard,
                    inputMode: $inputMode,
                    selectedCell: $selectedCell,
                    scale: nil, // No need to scale on iPad
                    elapsedTime: elapsedTime,
                    restartAction: { showRestartAlert = true }
                )

                Spacer()
            }
            .padding(.top, 40)
            .padding(.trailing)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    /// The view layout for portrait orientation.
    private var portraitLayout: some View {
        VStack(spacing: 20) {
            HeaderView(
                showSettings: $showSettings,
                showDifficultyPicker: $showDifficultyPicker,
                currentDifficulty: currentDifficulty
            )
            .padding(.top)
            
            GameBoardView(
                gameBoard: gameBoard,
                selectedCell: $selectedCell,
                isRelated: isRelated,
                isDarkMode: isDarkMode
            )
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .glassEffect(.regular.tint(.clear).interactive(), in: .rect(cornerRadius: 20))
            .padding(.horizontal)
            
            ControlAreaView(
                gameBoard: gameBoard,
                inputMode: $inputMode,
                selectedCell: $selectedCell,
                scale: nil,
                elapsedTime: elapsedTime,
                restartAction: { showRestartAlert = true }
            )
            
            Spacer()
        }
        .padding(.vertical)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    /// The view layout for the right landscape orientation.
    private var landscapeRightLayout: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Game board on the left. This section is unchanged.
                GameBoardView(
                    gameBoard: gameBoard,
                    selectedCell: $selectedCell,
                    isRelated: isRelated,
                    isDarkMode: isDarkMode
                )
                .aspectRatio(1, contentMode: .fit)
                .clipShape(ContainerRelativeShape())
                .glassEffect(.regular.tint(.clear).interactive(), in: ContainerRelativeShape())
                .padding(.vertical, 24)
                .padding(.horizontal, 26)
                
                // Controls on the right, with scaling.
                let designWidth: CGFloat = 428 // A reference width for scaling
                let scale = min(1.0, geometry.size.width / 2 / designWidth)
                
                VStack {
                    HeaderView(
                        showSettings: $showSettings,
                        showDifficultyPicker: $showDifficultyPicker,
                        currentDifficulty: currentDifficulty
                    )
                    .padding(.top)
                    .offset(y: 20*scale)
                    
                    ControlAreaView(
                        gameBoard: gameBoard,
                        inputMode: $inputMode,
                        selectedCell: $selectedCell,
                        scale: scale,
                        elapsedTime: elapsedTime,
                        restartAction: { showRestartAlert = true },
                        
                    )
                    .padding(.horizontal)
                    .offset(y: 30*scale)
                    
                    Spacer()
                }
                .scaleEffect(scale)
                .frame(width: geometry.size.width / 1.7)
                .offset(x: -15*scale)
            }
            .ignoresSafeArea()
        }
    }
    
    /// The view layout for the left landscape orientation.
    private var landscapeLeftLayout: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                
                let designWidth: CGFloat = 428 // A reference width for scaling
                let scale = min(1.0, geometry.size.width / 2 / designWidth)
                
                // Game board on the left. This section is unchanged.
                GameBoardView(
                    gameBoard: gameBoard,
                    selectedCell: $selectedCell,
                    isRelated: isRelated,
                    isDarkMode: isDarkMode
                )
                .aspectRatio(1, contentMode: .fit)
                .clipShape(ContainerRelativeShape())
                .glassEffect(.regular.tint(.clear).interactive(), in: ContainerRelativeShape())
                .padding(.vertical)
                .safeAreaPadding(.leading, 70*scale)
                
                // 修改这里：使用 geometry 的高度
                
                // Controls on the right, with scaling.
                
                VStack {
                    HeaderView(
                        showSettings: $showSettings,
                        showDifficultyPicker: $showDifficultyPicker,
                        currentDifficulty: currentDifficulty
                    )
                    .padding(.top)
                    .offset(y: 20*scale)
                    
                    ControlAreaView(
                        gameBoard: gameBoard,
                        inputMode: $inputMode,
                        selectedCell: $selectedCell,
                        scale: scale,
                        elapsedTime: elapsedTime,
                        restartAction: { showRestartAlert = true }
                    )
                    .padding(.horizontal)
                    .offset(y: 30*scale)
                    
                    Spacer()
                }
                .scaleEffect(scale)
                .frame(width: geometry.size.width / 1.6)
                .offset(x: -15*scale)
            }
            .ignoresSafeArea()
        }
    }
}
// MARK: - HeaderView
/**
 * @struct HeaderView
 * @brief A view that displays the game title and a settings button.
 */
struct HeaderView: View {
    @Binding var showSettings: Bool
    @Binding var showDifficultyPicker: Bool
    let currentDifficulty: Difficulty

    var body: some View {
        GlassEffectContainer {
            HStack {
                Button(action: { showDifficultyPicker = true }) {
                    HStack {
                        Text("Sudoku")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .padding()

                Spacer()

                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding()
                }
                
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - DifficultySelectionView
/**
 * @struct DifficultySelectionView
 * @brief A view for selecting the game difficulty.
 */
struct DifficultySelectionView: View {
    @Binding var currentDifficulty: Difficulty
    let restartAction: (Difficulty) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("选择难度")) {
                    Picker("难度", selection: $currentDifficulty) {
                        ForEach(Difficulty.allCases) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("切换难度")
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("确定") {
                    restartAction(currentDifficulty)
                    dismiss()
                }
            )
        }
    }
}

// MARK: - SettingsView
/**
 * @struct SettingsView
 * @brief A view for configuring game settings.
 */
struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @EnvironmentObject var gameBoard: GameBoard // 从环境中获取 gameBoard
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("外观")) {
                    Toggle("深色模式", isOn: $isDarkMode)
                }

                Section(header: Text("游戏")) {
                    // 使用 Picker 替换 Stepper
                    Picker("错误上限", selection: $gameBoard.maxErrors) {
                        ForEach(1...10, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button("完成") {
                dismiss()
            })
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
// MARK: - GameBoardView
/**
 * @struct GameBoardView
 * @brief A view that displays the 9x9 Sudoku grid.
 *
 * It arranges `CellView` instances in a grid and handles tap gestures
 * to update the selected cell.
 */
struct GameBoardView: View {
    /// The game board model, observed for changes to the grid.
    @ObservedObject var gameBoard: GameBoard
    /// A binding to the currently selected cell's coordinates.
    @Binding var selectedCell: (row: Int, col: Int)?
    /// A closure to check if a cell is related to the selected one.
    let isRelated: (_ selected: (row: Int, col: Int)?, _ current: (row: Int, col: Int)) -> Bool
    /// A flag indicating if dark mode is enabled.
    let isDarkMode: Bool

    var body: some View {
        let selectedValue = selectedCell.flatMap { gameBoard.grid[$0.row][$0.col].value }

        // Define a prominent separator color based on the dark mode setting.
        let separatorColor = isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.6)

        VStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { subgridRow in
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { subgridCol in
                        SubgridView(
                            gameBoard: gameBoard,
                            selectedCell: $selectedCell,
                            isRelated: isRelated,
                            selectedValue: selectedValue,
                            subgridRow: subgridRow,
                            subgridCol: subgridCol,
                            separatorColor: separatorColor
                        )
                    }
                }
            }
        }
        .background(separatorColor)
    }
}

// MARK: - SubgridView
/**
 * @struct SubgridView
 * @brief A view that displays a 3x3 subgrid of the Sudoku board.
 */
struct SubgridView: View {
    @ObservedObject var gameBoard: GameBoard
    @Binding var selectedCell: (row: Int, col: Int)?

    let isRelated: (_ selected: (row: Int, col: Int)?, _ current: (row: Int, col: Int)) -> Bool
    let selectedValue: Int?
    let subgridRow: Int
    let subgridCol: Int
    let separatorColor: Color

    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { localRow in
                HStack(spacing: 1) {
                    ForEach(0..<3, id: \.self) { localCol in
                        let row = subgridRow * 3 + localRow
                        let col = subgridCol * 3 + localCol

                        CellView(
                            cell: gameBoard.grid[row][col],
                            isSelected: selectedCell?.row == row && selectedCell?.col == col,
                            isRelated: isRelated(selectedCell, (row, col)),
                            selectedValue: selectedValue
                        )
                        .onTapGesture {
                            self.selectedCell = (row, col)
                        }
                        .onHover { isHovering in
                            if isHovering && UIDevice.current.userInterfaceIdiom == .pad {
                                self.selectedCell = (row, col)
                            }
                        }
                    }
                }
            }
        }
        .background(separatorColor)
    }
}
// MARK: - CellView
/**
 * @struct CellView
 * @brief A view for a single cell in the Sudoku grid.
 *
 * It displays the cell's value and changes its appearance based on whether it's
 * selected, related to the selected cell, fixed, or incorrect.
 */
struct CellView: View {
    /// The data model for the cell.
    let cell: Cell
    /// A flag indicating if this cell is the currently selected one.
    let isSelected: Bool
    /// A flag indicating if this cell is related to the selected one.
    let isRelated: Bool
    /// The value of the selected cell, used for highlighting matching numbers.
    let selectedValue: Int?

    var body: some View {
        let shouldHighlightAsSelected = isSelected || (
            selectedValue != nil && cell.value == selectedValue && !cell.isWrong
        )

        let foregroundColor: Color = cell.isWrong ? .red : (cell.isFixed ? .primary : .accentColor)

        Text(cell.value != nil ? "\(cell.value!)" : "")
            .font(.title2)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .foregroundColor(foregroundColor)
            .background(
                ZStack {
                    Color(UIColor.systemBackground)
                    if shouldHighlightAsSelected {
                        Color.blue.opacity(0.6)
                    } else if isRelated {
                        Color.blue.opacity(0.2)
                    }
                }
            )
    }
}

// MARK: - ControlAreaView
/**
 * @enum InputMode
 * @brief Defines the user interaction modes for the game.
 */
enum InputMode: String, CaseIterable {
    /// User can only select and view cells.
    case viewing = "查看"
    /// User can enter numbers into cells.
    case entering = "输入"
}
/**
 * @struct ControlAreaView
 * @brief A view containing game controls like the mode picker, error counter, timer, and number pad.
 */
struct ControlAreaView: View {
    /// A binding to the current number of errors.
    @ObservedObject var gameBoard: GameBoard
    /// A binding to the current input mode.
    @Binding var inputMode: InputMode
    /// A binding to the currently selected cell.
    @Binding var selectedCell: (row: Int, col: Int)?
    
    let scale: CGFloat?
    /// The elapsed game time to display.
    let elapsedTime: Int
    /// A closure to be executed when the restart button is tapped.
    let restartAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                ErrorCounterView(gameBoard: gameBoard)

                Spacer()

                TimerView(elapsedTime: elapsedTime)

                Spacer()

                ModeSwitchViewClicker(inputMode: $inputMode)
                
                Spacer()

                Button(action: restartAction) {
                    Image(systemName: "arrow.trianglehead.counterclockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding()
                        .glassEffect(.regular.tint(.black.opacity(0.1)).interactive(), in: .rect(cornerRadius: 20))
                }
            }
            .padding(.horizontal)
            
            if inputMode == .entering {
                NumberPadView(selectedCell: $selectedCell)
                .padding(.top)
                .transition(.scale.animation(.default))
                .offset(y: 20 * (scale ?? 0.0))
            }
        }
        .animation(.default, value: inputMode)
    }
}

// MARK: - ErrorCounterView
/**
 * @struct ErrorCounterView
 * @brief A view that displays the current number of errors out of the maximum allowed.
 */
struct ErrorCounterView: View {
    /// A binding to the current number of errors.
    @ObservedObject var gameBoard: GameBoard

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "xmark.circle")
                .font(.headline)
                .foregroundColor(.red)
            Text("\(gameBoard.errorCount)/\(gameBoard.maxErrors)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(gameBoard.errorCount > 0 ? .red : .primary)
                .monospacedDigit()
        }
        .padding()
        .background(.black.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
    }
}
// MARK: - TimerView
/**
 * @struct TimerView
 * @brief A view that displays the elapsed game time in a `MM:SS` format.
 */
struct TimerView: View {
    /// The total elapsed time in seconds.
    let elapsedTime: Int

    /// Formats the elapsed time into a `MM:SS` string.
    private var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
                .font(.headline)
                .foregroundColor(.orange)
            Text(formattedTime)
                .font(.headline)
                .fontWeight(.bold)
                .monospacedDigit()
        }
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular.tint(.black.opacity(0.1)).interactive(), in: .rect(cornerRadius: 20))
    }
}
// MARK: - ModeSwitchView
/**
 * @struct ModeSwitchView
 * @brief A simple toggle switch for changing the input mode.
 *
 * This view displays a keyboard icon and changes its background color to indicate
 * whether the game is in 'entering' (green) or 'viewing' (gray) mode.
 */
struct ModeSwitchViewClicker: View {
    /// A binding to the current input mode.
    @Binding var inputMode: InputMode

    var body: some View {
        Image(systemName: "keyboard")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(inputMode == .entering ? Color.green.opacity(0.9) : Color.primary)
            .padding()
            .glassEffect(.regular.tint(.black.opacity(0.1)).interactive(), in: .rect(cornerRadius: 20))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    inputMode = (inputMode == .viewing) ? .entering : .viewing
                }
            }
    }
}

/**
 * @struct ModeSwitchView
 * @brief A custom toggle switch for changing the input mode, inspired by GarageBand's UI.
 *
 * This view features a two-layered design with a draggable sliding thumb to switch
 * between viewing (locked, gray) and entering (pencil, green) modes.
 */
struct ModeSwitchViewSlider: View {
    /// A binding to the current input mode.
    @Binding var inputMode: InputMode

    /// State to track the drag gesture's offset.
    @State private var dragOffset: CGFloat = 0

    /// The animation applied when interacting with the switch.
    private var switchAnimation: Animation { .easeInOut(duration: 0.2) }

    private let switchWidth: CGFloat = 90
    private let switchHeight: CGFloat = 50
    private let cornerRadius: CGFloat = 20

    private var thumbWidth: CGFloat { switchHeight - 10 } // Thumb is slightly smaller than height
    private var travelDistance: CGFloat { switchWidth - thumbWidth - 10 } // 4px padding on each side

    var body: some View {
        // Inverted logic: 'viewing' is left, 'entering' is right.
        let thumbPositionX = (inputMode == .viewing ? -travelDistance / 2 : travelDistance / 2) + dragOffset

        ZStack {
            // Bottom layer with lock icons
            HStack {
                Image(systemName: "lock.open.fill")
                Spacer()
                Image(systemName: "lock.fill")
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 12)
            .frame(width: switchWidth, height: switchHeight)
            .background(Color.black.opacity(0.1))
            .cornerRadius(cornerRadius)
            .glassEffect(.regular,in: .rect(cornerRadius: cornerRadius))

            // Top sliding thumb with pencil icon
            ZStack {
                // Use RoundedRectangle for consistent corner radius
                RoundedRectangle(cornerRadius: cornerRadius - 4)
                    .frame(width: thumbWidth, height: thumbWidth)
                    // Change color based on the input mode
                    .foregroundColor(inputMode == .entering ? .green.opacity(0.8) : .black.opacity(0.2))
                    .glassEffect(.clear,in: .rect(cornerRadius: cornerRadius - 4))
                Image(systemName: "pencil")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(x: thumbPositionX)
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        // Calculate the starting position based on the current mode
                        let startX = inputMode == .viewing ? -travelDistance / 2 : travelDistance / 2
                        let newOffset = value.translation.width

                        // Clamp the final position within the travel distance
                        let clampedPosition = min(travelDistance / 2, max(-travelDistance / 2, startX + newOffset))

                        // Update the drag offset relative to the starting position
                        self.dragOffset = clampedPosition - startX
                    }
                    .onEnded { value in
                        // The final position of the thumb at the end of the drag
                        let finalThumbPosition = (inputMode == .viewing ? -travelDistance / 2 : travelDistance / 2) + value.translation.width

                        // Determine the new mode based on which side the thumb is on
                        let newMode: InputMode = finalThumbPosition > 0 ? .entering : .viewing

                        // Animate the change to the new state
                        withAnimation(switchAnimation) {
                            self.inputMode = newMode
                            self.dragOffset = 0
                        }
                    }
            )
        }
        .onTapGesture {
            // Explicitly animate the change only on tap
            withAnimation(switchAnimation) {
                inputMode = (inputMode == .viewing) ? .entering : .viewing
            }
        }
        .frame(width: switchWidth, height: switchHeight) // Ensure the ZStack has a defined frame
    }
}
// MARK: - NumberPadView
/**
 * @struct NumberPadView
 * @brief A view that displays a numeric keypad for entering numbers into the grid.
 */
struct NumberPadView: View {
    /// The game board model, used to enter or clear numbers.
    @EnvironmentObject var gameBoard: GameBoard
    /// A binding to the currently selected cell.
    @Binding var selectedCell: (row: Int, col: Int)?

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                ForEach(1..<6, id: \.self) { number in
                    NumberButton(number: number, selectedCell: $selectedCell)
                }
            }
            HStack(spacing: 15) {
                ForEach(6..<10, id: \.self) { number in
                    NumberButton(number: number, selectedCell: $selectedCell)
                }
                Button(action: {
                    if let selected = selectedCell {
                        gameBoard.clearCell(at: selected)
                    }
                }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity, maxHeight: 65)
                        .foregroundColor(.red)
                        .glassEffect(.regular.tint(.white.opacity(0.1)).interactive(), in: .rect(cornerRadius: 20))
                }
            }
        }
        .padding(.horizontal)
    }
}
// MARK: - NumberButtonView
/**
 * @struct NumberButton
 * @brief A button for the number pad.
 */
struct NumberButton: View {
    /// The number this button represents.
    let number: Int
    /// The game board model, used to enter the number.
    @EnvironmentObject var gameBoard: GameBoard
    /// A binding to the currently selected cell.
    @Binding var selectedCell: (row: Int, col: Int)?

    var body: some View {
        Button(action: {
            if let selected = selectedCell {
                gameBoard.enterNumber(number, at: selected)
            }
        }){
            Text("\(number)")
                .font(.system(size: 28))
                .frame(maxWidth: .infinity, maxHeight: 65)
                .foregroundColor(.primary)
                .glassEffect(.regular.tint(.white.opacity(0.1)).interactive(), in: .rect(cornerRadius: 20))
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for iPad
        ContentView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
            .previewDisplayName("iPad")
        
        // Preview for Portrait
        ContentView()
            .previewDisplayName("Portrait")

        // Preview for Landscape
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("landscapeLeft")
        ContentView()
            .previewInterfaceOrientation(.landscapeRight)
            .previewDisplayName("landscapeRight")
    }
}
