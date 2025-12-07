//
//  ContentView.swift
//  SudokuGame
//
//  Created by Jackthin Shin.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var puzzle: [[Int]] = [
        [5,3,0, 0,7,0, 0,0,0],
        [6,0,0, 1,9,5, 0,0,0],
        [0,9,8, 0,0,0, 0,6,0],
        [8,0,0, 0,6,0, 0,0,3],
        [4,0,0, 8,0,3, 0,0,1],
        [7,0,0, 0,2,0, 0,0,6],
        [0,6,0, 0,0,0, 2,8,0],
        [0,0,0, 4,1,9, 0,0,5],
        [0,0,0, 0,8,0, 0,7,9]
    ]
    @State private var board: [[Int]] = []
    @State private var selected: (r: Int, c: Int)?
    @State private var message: String = ""

    private func reset() {
        board = puzzle
        selected = nil
        message = ""
    }

    private func isFixed(_ r: Int, _ c: Int) -> Bool { puzzle[r][c] != 0 }

    private func conflicts(_ r: Int, _ c: Int, _ v: Int) -> Bool {
        guard v != 0 else { return false }
        for i in 0..<9 {
            if board[r][i] == v && i != c { return true }
            if board[i][c] == v && i != r { return true }
        }
        let br = (r/3)*3, bc = (c/3)*3
        for i in br..<(br+3) { for j in bc..<(bc+3) {
            if board[i][j] == v && !(i == r && j == c) { return true }
        }}
        return false
    }

    private func isComplete() -> Bool {
        for r in 0..<9 { for c in 0..<9 {
            let v = board[r][c]
            if v == 0 || conflicts(r, c, v) { return false }
        }}
        return true
    }

    private func input(_ v: Int) {
        guard let sel = selected, !isFixed(sel.r, sel.c) else { return }
        board[sel.r][sel.c] = v
        message = ""
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Sudoku Game").font(.title2).bold()
            gridView
            keypad
            HStack {
                Button("Reset", action: reset)
                Button("Erase") { input(0) }
                Button("Check") {
                    message = isComplete() ? "Congratulation!" : "Not solved or conflicts exist."
                }
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
            Text(message).foregroundColor(message == "Looks good!" ? .green : .red)
        }
        .padding()
        .onAppear { reset() }
    }

    private var br = 0
    private var bc = 0
    
    private var gridView: some View {
        ForEach(0..<3) { br in
            HStack {
                ForEach(0..<3) { bc in
                    VStack(spacing: 2) {
                        ForEach(br*3..<(br*3+3), id: \.self) { r in
                            HStack(spacing: 2) {
                                ForEach(bc*3..<(bc*3+3), id: \.self) { c in
                                    let v = board.indices.contains(r) && board[r].indices.contains(c) ? board[r][c] : 0
                                    CellView(value: v,
                                             fixed: isFixed(r, c),
                                             selected: selected?.r == r && selected?.c == c,
                                             conflicted: conflicts(r, c, v))
                                    .onTapGesture { selected = (r, c) }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, -4)
            }
        }
    }
    
    private var keypad: some View {
        HStack {
            ForEach(1...9, id: \.self) { n in
                Button(String(n)) { input(n) }
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

struct CellView: View {
    let value: Int
    let fixed: Bool
    let selected: Bool
    let conflicted: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(cellColor)
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(borderColor, lineWidth: selected ? 2 : 1)
            Text(value == 0 ? "" : String(value))
                .font(.system(size: 18, weight: fixed ? .bold : .regular))
                .foregroundStyle(fixed ? .primary : .secondary)
        }
        .frame(width: 36, height: 36)
    }

    private var cellColor: Color {
        if conflicted { return .red.opacity(0.25) }
        return Color(.secondarySystemBackground)
    }
    private var borderColor: Color {
        if selected { return .accentColor }
        return conflicted ? .red : .gray.opacity(0.6)
    }
}

#Preview {
    ContentView()
}
