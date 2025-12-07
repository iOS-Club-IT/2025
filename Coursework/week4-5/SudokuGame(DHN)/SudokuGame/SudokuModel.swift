//
//  SudokuModel.swift
//  SudokuGame
//
//  Created by 刁泓宁 on 2025/11/26.
//

import Foundation
import Combine

/**
 * @enum Difficulty
 * @brief Represents the difficulty levels of the game.
 */
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"
    case master = "大师"
    
    var id: String { self.rawValue }
}

/**
 * @struct Cell
 * @brief Represents a single cell in the Sudoku grid.
 */
struct Cell {
    var value: Int?
    let isFixed: Bool
    var isWrong: Bool = false
}

/**
 * @class GameBoard
 * @brief Manages the state and logic of the Sudoku game.
 */
class GameBoard: ObservableObject {
    @Published var grid: [[Cell]]
    @Published var errorCount: Int = 0
    @Published var maxErrors = 3
    
    private var solution: [[Int]]
    private var puzzle: [[Int]]
    

    // A static dictionary to hold puzzles for different difficulties.
    private static let puzzles: [Difficulty: (puzzle: [[Int]], solution: [[Int]])] = [
        .easy: (
            puzzle: [
                [1, 0, 0, 4, 8, 9, 0, 0, 6],
                [7, 3, 0, 0, 0, 0, 0, 4, 0],
                [0, 0, 0, 0, 0, 1, 2, 9, 5],
                [0, 0, 7, 1, 2, 0, 6, 0, 0],
                [5, 0, 0, 7, 0, 3, 0, 0, 1],
                [0, 0, 3, 0, 9, 6, 0, 0, 0],
                [9, 6, 2, 8, 0, 0, 0, 0, 0],
                [0, 8, 0, 0, 0, 0, 0, 1, 7],
                [4, 0, 0, 5, 1, 2, 0, 0, 3]
            ],
            solution: [
                [1, 2, 5, 4, 8, 9, 7, 3, 6],
                [7, 3, 9, 2, 5, 6, 8, 4, 1],
                [6, 4, 8, 3, 7, 1, 2, 9, 5],
                [8, 9, 7, 1, 2, 4, 6, 5, 3],
                [5, 1, 6, 7, 8, 3, 9, 2, 1],
                [2, 5, 3, 9, 9, 6, 1, 7, 8],
                [9, 6, 2, 8, 3, 7, 5, 1, 4],
                [3, 8, 4, 6, 4, 5, 9, 1, 7],
                [4, 7, 1, 5, 1, 2, 3, 8, 2]
            ]
        ),
        .medium: (
            puzzle: [
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
            solution: [
                [5, 3, 4, 6, 7, 8, 9, 1, 2],
                [6, 7, 2, 1, 9, 5, 3, 4, 8],
                [1, 9, 8, 3, 4, 2, 5, 6, 7],
                [8, 5, 9, 7, 6, 1, 4, 2, 3],
                [4, 2, 6, 8, 5, 3, 7, 9, 1],
                [7, 1, 3, 9, 2, 4, 8, 5, 6],
                [9, 6, 1, 5, 3, 7, 2, 8, 4],
                [2, 8, 7, 4, 1, 9, 6, 3, 5],
                [3, 4, 5, 2, 8, 6, 1, 7, 9]
            ]
        ),
        .hard: (
            puzzle: [
                [0, 0, 0, 6, 0, 0, 4, 0, 0],
                [7, 0, 0, 0, 0, 3, 6, 0, 0],
                [0, 0, 0, 0, 9, 1, 0, 8, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 5, 0, 1, 8, 0, 0, 0, 3],
                [0, 0, 0, 3, 0, 6, 0, 4, 5],
                [0, 4, 0, 2, 0, 0, 0, 6, 0],
                [9, 0, 3, 0, 0, 0, 0, 0, 0],
                [0, 2, 0, 0, 0, 0, 1, 0, 0]
            ],
            solution: [
                [1, 3, 2, 6, 5, 8, 4, 9, 7],
                [7, 9, 8, 4, 2, 3, 6, 5, 1],
                [6, 5, 4, 7, 9, 1, 3, 8, 2],
                [4, 8, 6, 5, 3, 2, 9, 1, 7],
                [2, 5, 9, 1, 8, 7, 4, 6, 3],
                [3, 1, 7, 9, 4, 6, 2, 8, 5],
                [8, 4, 1, 2, 7, 9, 5, 6, 3],
                [9, 7, 3, 8, 6, 5, 1, 2, 4],
                [5, 2, 6, 3, 1, 4, 7, 9, 8]
            ]
        ),
        .master: (
            puzzle: [
                [8, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 3, 6, 0, 0, 0, 0, 0],
                [0, 7, 0, 0, 9, 0, 2, 0, 0],
                [0, 5, 0, 0, 0, 7, 0, 0, 0],
                [0, 0, 0, 0, 4, 5, 7, 0, 0],
                [0, 0, 0, 1, 0, 0, 0, 3, 0],
                [0, 0, 1, 0, 0, 0, 0, 6, 8],
                [0, 0, 8, 5, 0, 0, 0, 1, 0],
                [0, 9, 0, 0, 0, 0, 4, 0, 0]
            ],
            solution: [
                [8, 1, 2, 7, 5, 3, 6, 4, 9],
                [9, 4, 3, 6, 8, 2, 1, 7, 5],
                [6, 7, 5, 4, 9, 1, 2, 8, 3],
                [1, 5, 4, 2, 3, 7, 8, 9, 6],
                [3, 6, 9, 8, 4, 5, 7, 2, 1],
                [2, 8, 7, 1, 6, 9, 5, 3, 4],
                [5, 2, 1, 9, 7, 4, 3, 6, 8],
                [4, 3, 8, 5, 2, 6, 9, 1, 7],
                [7, 9, 6, 3, 1, 8, 4, 5, 2]
            ]
        )
    ]

    /**
     * @brief Initializes the game board with a puzzle of a specific difficulty.
     * @param difficulty The desired difficulty level.
     */
    init(difficulty: Difficulty) {
        let gameData = GameBoard.puzzles[difficulty] ?? GameBoard.puzzles[.medium]!
        self.puzzle = gameData.puzzle
        self.solution = gameData.solution
        
        self.grid = self.puzzle.map { row in
            row.map { value in
                Cell(value: value == 0 ? nil : value, isFixed: value != 0, isWrong: false)
            }
        }
    }

    /**
     * @brief Updates the game board to a new difficulty.
     * @param difficulty The new difficulty level.
     */
    func update(difficulty: Difficulty) {
        let gameData = GameBoard.puzzles[difficulty] ?? GameBoard.puzzles[.medium]!
        self.puzzle = gameData.puzzle
        self.solution = gameData.solution
        self.reset()
    }

    func enterNumber(_ number: Int, at position: (row: Int, col: Int)) {
        guard !grid[position.row][position.col].isFixed else { return }
        guard errorCount < maxErrors else { return }

        if solution[position.row][position.col] == number {
            grid[position.row][position.col].value = number
            grid[position.row][position.col].isWrong = false
        } else {
            if grid[position.row][position.col].value != number {
                grid[position.row][position.col].value = number
                grid[position.row][position.col].isWrong = true
                errorCount += 1
            }
        }
    }

    func clearCell(at position: (row: Int, col: Int)) {
        guard !grid[position.row][position.col].isFixed else { return }
        
        grid[position.row][position.col].value = nil
        grid[position.row][position.col].isWrong = false
    }
    
    func reset() {
        self.grid = self.puzzle.map { row in
            row.map { value in
                Cell(value: value == 0 ? nil : value, isFixed: value != 0, isWrong: false)
            }
        }
        self.errorCount = 0
    }
}
