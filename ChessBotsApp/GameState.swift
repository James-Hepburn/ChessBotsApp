struct GameState {
    static func generateLegalMoves (board: inout ChessBoard) -> [Move] {
        var pseudoMoves = MoveGenerator.generatePseudoLegalMoves (board: board)
        var legalMoves: [Move] = []
        
        for row in 0...7 {
                for col in 0...7 {
                    guard let piece = board.board [row][col], piece.isWhite == board.whiteToMove, piece.type == .king else { continue }
                    MoveGenerator.generateCastlingMoves (board: board, row: row, piece: piece, moves: &pseudoMoves)
                }
            }

        for move in pseudoMoves {
            board.makeMove (move)
            
            let kingPosition = board.whiteToMove ? board.blackKingPosition : board.whiteKingPosition

            if !AttackDetector.isSquareAttacked (board: board, square: kingPosition, byWhite: board.whiteToMove) {
                legalMoves.append (move)
            }

            board.undoMove ()
        }

        return legalMoves
    }

    static func isCheck (board: ChessBoard) -> Bool {
        let kingPosition = board.whiteToMove ? board.whiteKingPosition : board.blackKingPosition
        return AttackDetector.isSquareAttacked (board: board, square: kingPosition, byWhite: !board.whiteToMove)
    }

    static func isCheckmate (board: inout ChessBoard) -> Bool {
        return isCheck (board: board) && generateLegalMoves (board: &board).isEmpty
    }

    static func isStalemate (board: inout ChessBoard) -> Bool {
        return !isCheck (board: board) && generateLegalMoves (board: &board).isEmpty
    }
}
