import SwiftUI

struct ChessGameView: View {
    @State private var board = ChessBoard ()
    @State private var selectedSquare: (Int, Int)?
    @State private var legalMovesForSelected: [Move] = []
    @State private var pendingPromotionMove: Move? = nil
    @State private var showPromotionPicker = false
    @State private var gameOverMessage: String? = nil
    @State private var isBotThinking = false

    let difficulty: Difficulty
    let boardSize = 8

    var body: some View {
        VStack {
            if isBotThinking {
                Text ("Bot is thinking…")
                    .foregroundColor (.gray)
                    .font (.caption)
                    .padding (.top, 4)
            } else {
                Text (board.whiteToMove ? "Your turn" : "")
                    .foregroundColor (.white)
                    .font (.caption)
                    .padding (.top, 4)
            }

            chessBoard
                .padding ()
        }
        .frame (maxWidth: .infinity, maxHeight: .infinity)
        .background (Color.black.ignoresSafeArea ())
        .sheet (isPresented: $showPromotionPicker) {
            VStack (spacing: 20) {
                Text ("Choose Promotion")
                    .font (.title.bold ())
                    .padding ()

                HStack (spacing: 20) {
                    ForEach ([PieceType.queen, .rook, .bishop, .knight], id: \.self) { pieceType in
                        Button {
                            if var move = pendingPromotionMove {
                                move.promotionPiece = pieceType
                                board.makeMove (move)
                                checkGameOver ()
                                triggerBotMove ()
                                pendingPromotionMove = nil
                                showPromotionPicker = false
                            }
                        } label: {
                            Image (ChessPiece (type: pieceType, isWhite: true, hasMoved: false).imageName)
                                .resizable ()
                                .scaledToFit ()
                                .frame (width: 50, height: 50)
                        }
                    }
                }
                .padding ()
            }
            .presentationDetents ([.fraction (0.25)])
        }
        .overlay {
            if let message = gameOverMessage {
                ZStack {
                    Color.black.opacity (0.8)
                    VStack (spacing: 20) {
                        Text (message)
                            .font (.title.bold ())
                            .foregroundColor (.white)
                            .multilineTextAlignment (.center)
                            .padding ()

                        Button ("Play Again") {
                            board = ChessBoard ()
                            gameOverMessage = nil
                            selectedSquare = nil
                            legalMovesForSelected = []
                            isBotThinking = false
                        }
                        .frame (width: 140, height: 50)
                        .background (Color.purple)
                        .foregroundColor (.white)
                        .cornerRadius (10)
                        .font (.title2.bold ())

                        Button ("Close") {
                            gameOverMessage = nil
                        }
                        .frame (width: 140, height: 50)
                        .background (Color.gray.opacity (0.4))
                        .foregroundColor (.white)
                        .cornerRadius (10)
                        .font (.title2.bold ())
                    }
                }
                .ignoresSafeArea ()
            }
        }
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
                                Image (piece.imageName)
                                    .resizable ()
                                    .scaledToFit ()
                                    .frame (width: 36, height: 36)
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

    func triggerBotMove () {
        guard !board.whiteToMove else { return }
        guard gameOverMessage == nil else { return }

        isBotThinking = true

        var boardCopy = board
        let minThinkTime: TimeInterval = difficulty == .easy ? 0.6 : 0.0

        DispatchQueue.global (qos: .userInitiated).async {
            let start = Date ()
            let move = ChessBot.makeMove (board: &boardCopy, difficulty: difficulty)
            let elapsed = Date ().timeIntervalSince (start)
            let remaining = max (0, minThinkTime - elapsed)

            DispatchQueue.main.asyncAfter (deadline: .now () + remaining) {
                isBotThinking = false
                guard let move = move else { return }
                board.makeMove (move)
                checkGameOver ()
            }
        }
    }

    func checkGameOver () {
        if GameState.isCheckmate (board: &board) {
            gameOverMessage = board.whiteToMove ? "Black wins by checkmate!" : "White wins by checkmate!"
        } else if GameState.isStalemate (board: &board) {
            gameOverMessage = "Stalemate — it's a draw!"
        }
    }

    func isPromotion (_ move: Move) -> Bool {
        guard let piece = board.board [move.from.0][move.from.1] else { return false }
        return piece.type == .pawn && (move.to.0 == 0 || move.to.0 == 7)
    }

    func handleTap (row: Int, col: Int) {
        guard board.whiteToMove, !isBotThinking else { return }
        let tappedSquare = (row, col)

        if selectedSquare != nil {
            if let move = legalMovesForSelected.first (where: { $0.to == tappedSquare }) {
                if isPromotion (move) {
                    pendingPromotionMove = move
                    showPromotionPicker = true
                } else {
                    board.makeMove (move)
                    checkGameOver ()
                    triggerBotMove ()
                }

                selectedSquare = nil
                legalMovesForSelected = []
                return
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
        legalMovesForSelected = allLegal.filter { $0.from == (row, col) }
    }

    func squareColor (row: Int, col: Int) -> Color {
        if selectedSquare?.0 == row && selectedSquare?.1 == col {
            return Color.yellow
        }

        if legalMovesForSelected.contains (where: { $0.to == (row, col) }) {
            return Color.green.opacity (0.6)
        }

        return (row + col).isMultiple (of: 2) ? Color.white : Color.purple
    }
}

#Preview {
    ChessGameView (difficulty: .easy)
}
