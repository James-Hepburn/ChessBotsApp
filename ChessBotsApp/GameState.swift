struct GameState {
    static func generateLegalMoves (board: inout ChessBoard) -> [Move] {
        let pseudoMoves = MoveGenerator.generatePseudoLegalMoves (board: board)
        var legalMoves: [Move] = []

        for move in pseudoMoves {
            let captured = board.board [move.to.0][move.to.1]
            board.makeMove (move)
            
            var kingPosition = board.blackKingPosition
            
            if board.whiteToMove {
                kingPosition = board.whiteKingPosition
            }

            if !AttackDetector.isSquareAttacked (board: board, square: kingPosition, byWhite: board.whiteToMove) {
                legalMoves.append (move)
            }

            board.undoMove ()
            board.board [move.to.0][move.to.1] = captured
        }

        return legalMoves
    }

    static func isCheck (board: ChessBoard) -> Bool {
        var kingPosition = board.blackKingPosition
        
        if board.whiteToMove {
            kingPosition = board.whiteKingPosition
        }
        
        return AttackDetector.isSquareAttacked (board: board, square: kingPosition, byWhite: !board.whiteToMove)
    }

    static func isCheckmate (board: inout ChessBoard) -> Bool {
        return isCheck (board: board) && generateLegalMoves (board: &board).isEmpty
    }

    static func isStalemate (board: inout ChessBoard) -> Bool {
        return !isCheck (board: board) && generateLegalMoves (board: &board).isEmpty
    }
}
