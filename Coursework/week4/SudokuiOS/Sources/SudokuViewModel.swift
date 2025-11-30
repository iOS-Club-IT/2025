import SwiftUI
import Combine

class SudokuViewModel: ObservableObject {
    @Published var board: [[String]]
    @Published var message: String = "Sudoku Game"
    @Published var solvedIndices: Set<String> = [] // Store "row,col" of solved cells for styling
    
    private var solver = SudokuSolver()
    
    init() {
        self.board = Array(repeating: Array(repeating: "", count: 9), count: 9)
    }
    
    func loadGame(difficulty: Difficulty) {
        let newBoard = SudokuDatabase.getPuzzle(difficulty: difficulty)
        solver.board = newBoard
        updateBoardFromSolver()
        message = "Loaded \(difficulty.rawValue) Puzzle"
        solvedIndices.removeAll()
    }
    
    func updateBoardFromSolver() {
        for r in 0..<9 {
            for c in 0..<9 {
                let val = solver.board[r][c]
                board[r][c] = val == 0 ? "" : String(val)
            }
        }
    }
    
    func syncGuiToBackend() {
        var currentBoard: [[Int]] = []
        for r in 0..<9 {
            var rowData: [Int] = []
            for c in 0..<9 {
                if let val = Int(board[r][c]) {
                    rowData.append(val)
                } else {
                    rowData.append(0)
                }
            }
            currentBoard.append(rowData)
        }
        solver.board = currentBoard
    }
    
    func solve() {
        syncGuiToBackend()
        
        // Self check (simple version based on Python code)
        // In Python: self_check_isvalid() checks if current numbers are valid placements
        // We can skip or implement similarly. Let's trust runSolver will fail if invalid start?
        // Actually, the Python code removes the number, checks validity, then puts it back.
        
        if !runSelfCheck() {
            message = "[WARNING] Contradiction appears"
            return
        }
        
        if solver.runSolver() {
            // Update UI
            for r in 0..<9 {
                for c in 0..<9 {
                    let oldVal = board[r][c]
                    let newVal = solver.board[r][c]
                    board[r][c] = String(newVal)
                    
                    // If it changed or was empty, mark as solved
                    if oldVal.isEmpty || oldVal != String(newVal) {
                        solvedIndices.insert("\(r),\(c)")
                    }
                }
            }
            
            let timeStr = String(format: "%.2f", solver.executionTime)
            message = "🕒 Time: \(timeStr) ms | 🔢 Steps: \(solver.steps) | 🔙 Backtracks: \(solver.backtracks)"
            solver.printMetrics()
        } else {
            message = "[ERROR] Unsolvable puzzle"
        }
    }
    
    func runSelfCheck() -> Bool {
        let currentBoard = solver.board
        for r in 0..<9 {
            for c in 0..<9 {
                let num = currentBoard[r][c]
                if num != 0 {
                    solver.board[r][c] = 0
                    if !solver.isValid(row: r, col: c, num: num) {
                        solver.board[r][c] = num
                        return false
                    }
                    solver.board[r][c] = num
                }
            }
        }
        return true
    }
    
    func clear() {
        solver = SudokuSolver() // Reset solver
        board = Array(repeating: Array(repeating: "", count: 9), count: 9)
        solvedIndices.removeAll()
        message = "Clear!"
    }
}
