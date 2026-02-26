struct AttackDetector {
    static func isSquareAttacked (board: ChessBoard, square: (Int, Int), byWhite: Bool) -> Bool {
        var tempBoard = board
        tempBoard.whiteToMove = byWhite

        let moves = MoveGenerator.generatePseudoLegalMoves (board: tempBoard)

        for move in moves {
            if move.to == square {
                return true
            }
        }

        return false
    }
}
