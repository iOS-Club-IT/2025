import SwiftUI
import Combine

enum Difficulty: String, CaseIterable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"
}

struct SudokuDatabase {
    static let easyPuzzles: [[[Int]]] = [
        [
            [5, 3, 0, 0, 7, 0, 0, 0, 0],
            [6, 0, 0, 1, 9, 5, 0, 0, 0],
            [0, 9, 8, 0, 0, 0, 0, 6, 0],
            [8, 0, 0, 0, 6, 0, 0, 0, 3],
            [4, 0, 0, 8, 0, 3, 0, 0, 1],
            [7, 0, 0, 0, 2, 0, 0, 0, 6],
            [0, 6, 0, 0, 0, 0, 2, 8, 0],
            [0, 0, 0, 4, 1, 9, 0, 0, 5],
            [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ],
        [
            [0, 0, 0, 2, 6, 0, 7, 0, 1],
            [6, 8, 0, 0, 7, 0, 0, 9, 0],
            [1, 9, 0, 0, 0, 4, 5, 0, 0],
            [8, 2, 0, 1, 0, 0, 0, 4, 0],
            [0, 0, 4, 6, 0, 2, 9, 0, 0],
            [0, 5, 0, 0, 0, 3, 0, 2, 8],
            [0, 0, 9, 3, 0, 0, 0, 7, 4],
            [0, 4, 0, 0, 5, 0, 0, 3, 6],
            [7, 0, 3, 0, 1, 8, 0, 0, 0]
        ]
    ]

    static let mediumPuzzles: [[[Int]]] = [
        [
            [0, 0, 0, 6, 0, 0, 4, 0, 0],
            [7, 0, 0, 0, 0, 3, 6, 0, 0],
            [0, 0, 0, 0, 9, 1, 0, 8, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 5, 0, 1, 8, 0, 0, 0, 3],
            [0, 0, 0, 3, 0, 6, 0, 4, 5],
            [0, 4, 0, 2, 0, 0, 0, 6, 0],
            [9, 0, 3, 0, 0, 0, 0, 0, 0],
            [0, 2, 0, 0, 0, 0, 1, 0, 0]
        ]
    ]

    static let hardPuzzles: [[[Int]]] = [
        [
            [0, 2, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 6, 0, 0, 0, 0, 3],
            [0, 7, 4, 0, 8, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 3, 0, 0, 2],
            [0, 8, 0, 0, 4, 0, 0, 1, 0],
            [6, 0, 0, 5, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 1, 0, 7, 8, 0],
            [5, 0, 0, 0, 0, 9, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 4, 0]
        ]
    ]
    
    static func getPuzzle(difficulty: Difficulty) -> [[Int]] {
        switch difficulty {
        case .easy:
            return easyPuzzles.randomElement() ?? easyPuzzles[0]
        case .medium:
            return mediumPuzzles.randomElement() ?? mediumPuzzles[0]
        case .hard:
            return hardPuzzles.randomElement() ?? hardPuzzles[0]
        }
    }
}

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
