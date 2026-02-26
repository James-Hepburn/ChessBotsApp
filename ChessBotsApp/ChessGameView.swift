import SwiftUI

struct ChessGameView: View {
    @State private var board = ChessBoard ()
    @State private var selectedSquare: (Int, Int)?
    @State private var legalMovesForSelected: [(Int, Int)] = []
    
    let difficulty: Difficulty
    let boardSize = 8
    
    var body: some View {
        VStack {
            chessBoard
                .padding ()
        }
        .frame (maxWidth: .infinity, maxHeight: .infinity)
        .background (Color.black.ignoresSafeArea ())
    }
    
    var chessBoard: some View {
        VStack (spacing: 2) {
            ForEach (0..<boardSize, id: \.self) { row in
                HStack (spacing: 2) {
                    ForEach (0..<boardSize, id: \.self) { col in
                        ZStack {
                            Rectangle ()
                                .fill (squareColor (row: row, col: col))
                                .frame (width: 40, height: 40)

                            if let piece = board.board [row][col] {
                                Text (piece.symbol)
                                    .font (.title.bold ())
                            }
                        }
                        .onTapGesture {
                            handleTap (row: row, col: col)
                        }
                    }
                }
            }
        }
    }
    
    func handleTap (row: Int, col: Int) {
        guard board.whiteToMove else { return }

        let tappedSquare = (row, col)

        if let selected = selectedSquare {
            if legalMovesForSelected.contains (where: { $0 == tappedSquare }) {
                let allLegal = GameState.generateLegalMoves(board: &board)
                if let move = allLegal.first (where: { $0.from == selected && $0.to == tappedSquare }) {
                    board.makeMove (move)
                    selectedSquare = nil
                    legalMovesForSelected = []
                    return
                }
            }

            if let piece = board.board [row][col], piece.isWhite {
                selectSquare (row: row, col: col)
                return
            }

            selectedSquare = nil
            legalMovesForSelected = []
        } else {
            if let piece = board.board [row][col], piece.isWhite {
                selectSquare (row: row, col: col)
            }
        }
    }
    
    func selectSquare (row: Int, col: Int) {
        selectedSquare = (row, col)
        let allLegal = GameState.generateLegalMoves (board: &board)
        legalMovesForSelected = allLegal
            .filter { $0.from == (row, col) }
            .map { $0.to }
    }
    
    func squareColor (row: Int, col: Int) -> Color {
        if selectedSquare?.0 == row && selectedSquare?.1 == col {
            return Color.yellow
        }
        
        if legalMovesForSelected.contains (where: { $0 == (row, col) }) {
            return Color.green.opacity (0.6)
        }
        
        return (row + col).isMultiple (of: 2) ? Color.white : Color.purple
    }
}

#Preview {
    ChessGameView (difficulty: .easy)
}
