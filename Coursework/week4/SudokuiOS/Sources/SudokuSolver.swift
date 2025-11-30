import Foundation

class SudokuSolver {
    var board: [[Int]]
    
    // Metrics
    var steps: Int = 0
    var recursiveCalls: Int = 0
    var backtracks: Int = 0
    var startTime: Date?
    var executionTime: TimeInterval = 0
    
    init() {
        self.board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    }
    
    func loadFromCSV(content: String) -> Bool {
        self.board = []
        let rows = content.components(separatedBy: .newlines)
        
        for row in rows {
            let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedRow.isEmpty { continue }
            
            let components = trimmedRow.components(separatedBy: ",")
            let numbers = components.compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            
            if numbers.count == 9 {
                self.board.append(numbers)
            }
        }
        
        if self.board.count != 9 {
            print("[Error] Invalid row count in CSV")
            return false
        }
        
        print("[Succeed] File loaded")
        return true
    }
    
    func isValid(row: Int, col: Int, num: Int) -> Bool {
        // Row check
        for x in 0..<9 {
            if self.board[row][x] == num {
                return false
            }
        }
        
        // Column check
        for x in 0..<9 {
            if self.board[x][col] == num {
                return false
            }
        }
        
        // 3x3 box check
        let startRow = row - row % 3
        let startCol = col - col % 3
        for i in 0..<3 {
            for j in 0..<3 {
                if self.board[i + startRow][j + startCol] == num {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func solveAlgorithm() -> Bool {
        self.recursiveCalls += 1
        
        for i in 0..<9 {
            for j in 0..<9 {
                if self.board[i][j] == 0 {
                    for num in 1...9 {
                        self.steps += 1
                        if self.isValid(row: i, col: j, num: num) {
                            self.board[i][j] = num
                            
                            if self.solveAlgorithm() {
                                return true
                            }
                            
                            // Backtracking
                            self.board[i][j] = 0
                            self.backtracks += 1
                        }
                    }
                    return false
                }
            }
        }
        return true
    }
    
    func runSolver() -> Bool {
        self.steps = 0
        self.recursiveCalls = 0
        self.backtracks = 0
        
        self.startTime = Date()
        
        let success = self.solveAlgorithm()
        
        if let start = self.startTime {
            self.executionTime = Date().timeIntervalSince(start) * 1000 // Convert to ms
        }
        
        return success
    }
    
    func printMetrics() {
        print("\n")
        print(String(format: "Execution Time: %.4f ms", self.executionTime))
        print("Total Steps (Attempts): \(self.steps)")
        print("Recursive Calls: \(self.recursiveCalls)")
        print("Backtracks: \(self.backtracks)")
        print("\n")
    }
}
