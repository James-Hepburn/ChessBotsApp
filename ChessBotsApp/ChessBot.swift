struct ChessBot {
    static let pieceValues: [PieceType: Int] = [
        .pawn: 100,
        .knight: 320,
        .bishop: 330,
        .rook: 500,
        .queen: 900,
        .king: 20000
    ]
    
    static func makeMove (board: inout ChessBoard, difficulty: Difficulty) -> Move? {
        let legalMoves = GameState.generateLegalMoves (board: &board)
        guard !legalMoves.isEmpty else { return nil }
        
        switch difficulty {
        case .easy:
            return easyMove (moves: legalMoves)
        case .medium:
            return bestMove (board: &board, moves: legalMoves, depth: 2)
        case .hard:
            return bestMove (board: &board, moves: legalMoves, depth: 4)
        }
    }
    
    static func easyMove (moves: [Move]) -> Move {
        return moves.randomElement ()!
    }
    
    static func bestMove (board: inout ChessBoard, moves: [Move], depth: Int) -> Move {
        var bestMove = moves [0]
        var bestScore = Int.min
        
        for move in moves {
            board.makeMove (move)
            let score = -minimax (board: &board, depth: depth - 1, alpha: Int.min + 1, beta: Int.max)
            board.undoMove ()
            
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        return bestMove
    }
    
    static func minimax (board: inout ChessBoard, depth: Int, alpha: Int, beta: Int) -> Int {
        if depth == 0 {
            return evaluate (board: board)
        }
        
        let moves = GameState.generateLegalMoves (board: &board)
        
        if moves.isEmpty {
            if GameState.isCheck (board: board) {
                return -99999
            }
            return 0
        }
        
        var alpha = alpha
        
        for move in moves {
            board.makeMove (move)
            let score = -minimax (board: &board, depth: depth - 1, alpha: -beta, beta: -alpha)
            board.undoMove ()
            
            if score > alpha {
                alpha = score
            }
            if alpha >= beta {
                break
            }
        }
        
        return alpha
    }
    
    static func evaluate (board: ChessBoard) -> Int {
        var score = 0
        
        for row in 0...7 {
            for col in 0...7 {
                guard let piece = board.board [row][col] else { continue }
                let value = pieceValues [piece.type] ?? 0

                if piece.isWhite != board.whiteToMove {
                    score -= value
                } else {
                    score += value
                }
            }
        }
        
        return score
    }
}
