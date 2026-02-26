import SwiftUI

struct ChessGameView: View {
    @State private var board = ChessBoard ()
    @State private var selectedSquare: (Int, Int)?
    @State private var isWhiteTurn = true
    
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
                            if let selected = selectedSquare {
                                board.movePiece (from: selected, to: (row, col))
                                selectedSquare = nil
                            } else if board.board [row][col] != nil {
                                selectedSquare = (row, col)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func squareColor (row: Int, col: Int) -> Color {
        if selectedSquare?.0 == row && selectedSquare?.1 == col {
            return Color.yellow
        }
        
        return (row + col).isMultiple (of: 2) ? Color.white : Color.purple
    }
}

#Preview {
    ChessGameView (difficulty: .easy)
}
