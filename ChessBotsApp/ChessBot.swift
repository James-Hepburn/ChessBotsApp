struct ChessBot {
    static let pieceValues: [PieceType: Int] = [
        .pawn: 100,
        .knight: 320,
        .bishop: 330,
        .rook: 500,
        .queen: 900,
        .king: 20000
    ]

    static let pawnTable: [[Int]] = [
        [ 0,  0,  0,  0,  0,  0,  0,  0],
        [50, 50, 50, 50, 50, 50, 50, 50],
        [10, 10, 20, 30, 30, 20, 10, 10],
        [ 5,  5, 10, 25, 25, 10,  5,  5],
        [ 0,  0,  0, 20, 20,  0,  0,  0],
        [ 5, -5,-10,  0,  0,-10, -5,  5],
        [ 5, 10, 10,-20,-20, 10, 10,  5],
        [ 0,  0,  0,  0,  0,  0,  0,  0]
    ]

    static let knightTable: [[Int]] = [
        [-50,-40,-30,-30,-30,-30,-40,-50],
        [-40,-20,  0,  0,  0,  0,-20,-40],
        [-30,  0, 10, 15, 15, 10,  0,-30],
        [-30,  5, 15, 20, 20, 15,  5,-30],
        [-30,  0, 15, 20, 20, 15,  0,-30],
        [-30,  5, 10, 15, 15, 10,  5,-30],
        [-40,-20,  0,  5,  5,  0,-20,-40],
        [-50,-40,-30,-30,-30,-30,-40,-50]
    ]

    static let bishopTable: [[Int]] = [
        [-20,-10,-10,-10,-10,-10,-10,-20],
        [-10,  0,  0,  0,  0,  0,  0,-10],
        [-10,  0,  5, 10, 10,  5,  0,-10],
        [-10,  5,  5, 10, 10,  5,  5,-10],
        [-10,  0, 10, 10, 10, 10,  0,-10],
        [-10, 10, 10, 10, 10, 10, 10,-10],
        [-10,  5,  0,  0,  0,  0,  5,-10],
        [-20,-10,-10,-10,-10,-10,-10,-20]
    ]

    static let rookTable: [[Int]] = [
        [ 0,  0,  0,  0,  0,  0,  0,  0],
        [ 5, 10, 10, 10, 10, 10, 10,  5],
        [-5,  0,  0,  0,  0,  0,  0, -5],
        [-5,  0,  0,  0,  0,  0,  0, -5],
        [-5,  0,  0,  0,  0,  0,  0, -5],
        [-5,  0,  0,  0,  0,  0,  0, -5],
        [-5,  0,  0,  0,  0,  0,  0, -5],
        [ 0,  0,  0,  5,  5,  0,  0,  0]
    ]

    static let queenTable: [[Int]] = [
        [-20,-10,-10, -5, -5,-10,-10,-20],
        [-10,  0,  0,  0,  0,  0,  0,-10],
        [-10,  0,  5,  5,  5,  5,  0,-10],
        [ -5,  0,  5,  5,  5,  5,  0, -5],
        [  0,  0,  5,  5,  5,  5,  0, -5],
        [-10,  5,  5,  5,  5,  5,  0,-10],
        [-10,  0,  5,  0,  0,  0,  0,-10],
        [-20,-10,-10, -5, -5,-10,-10,-20]
    ]

    static let kingMiddleTable: [[Int]] = [
        [-30,-40,-40,-50,-50,-40,-40,-30],
        [-30,-40,-40,-50,-50,-40,-40,-30],
        [-30,-40,-40,-50,-50,-40,-40,-30],
        [-30,-40,-40,-50,-50,-40,-40,-30],
        [-20,-30,-30,-40,-40,-30,-30,-20],
        [-10,-20,-20,-20,-20,-20,-20,-10],
        [ 20, 20,  0,  0,  0,  0, 20, 20],
        [ 20, 30, 10,  0,  0, 10, 30, 20]
    ]

    static func pieceSquareValue (piece: ChessPiece, row: Int, col: Int) -> Int {
        let r = piece.isWhite ? row : (7 - row)
        switch piece.type {
        case .pawn:   return pawnTable [r][col]
        case .knight: return knightTable [r][col]
        case .bishop: return bishopTable [r][col]
        case .rook:   return rookTable [r][col]
        case .queen:  return queenTable [r][col]
        case .king:   return kingMiddleTable [r][col]
        }
    }

    static func makeMove (board: inout ChessBoard, difficulty: Difficulty) -> Move? {
        let legalMoves = GameState.generateLegalMoves (board: &board)
        guard !legalMoves.isEmpty else { return nil }

        switch difficulty {
        case .easy:
            return easyMove (moves: legalMoves)
        case .medium:
            return bestMove (board: &board, moves: legalMoves, depth: 3)
        case .hard:
            return bestMove (board: &board, moves: legalMoves, depth: 4)
        }
    }

    static func easyMove (moves: [Move]) -> Move {
        return moves.randomElement ()!
    }

    static func bestMove (board: inout ChessBoard, moves: [Move], depth: Int) -> Move {
        var bestMove = moves [0]
        var bestScore = Int.min + 1
        var alpha = Int.min + 1
        let beta = Int.max

        let ordered = orderMoves (moves)

        for move in ordered {
            board.makeMove (move)
            let score = -minimax (board: &board, depth: depth - 1, alpha: -beta, beta: -alpha)
            board.undoMove ()

            if score > bestScore {
                bestScore = score
                bestMove = move
            }
            if score > alpha {
                alpha = score
            }
        }

        return bestMove
    }

    static func generateMovesForSearch (board: inout ChessBoard) -> [Move] {
        var pseudo = MoveGenerator.generatePseudoLegalMoves (board: board)

        for row in 0...7 {
            for col in 0...7 {
                guard let piece = board.board [row][col],
                      piece.isWhite == board.whiteToMove,
                      piece.type == .king else { continue }
                MoveGenerator.generateCastlingMoves (board: board, row: row, piece: piece, moves: &pseudo)
            }
        }

        var legal: [Move] = []
        legal.reserveCapacity (pseudo.count)

        for move in pseudo {
            board.makeMove (move)
            let kingPos = board.whiteToMove ? board.blackKingPosition : board.whiteKingPosition
            if !AttackDetector.isSquareAttacked (board: board, square: kingPos, byWhite: board.whiteToMove) {
                legal.append (move)
            }
            board.undoMove ()
        }

        return legal
    }

    static func orderMoves (_ moves: [Move]) -> [Move] {
        return moves.sorted { a, b in
            let aVal = (a.captured != nil ? 1 : 0)
            let bVal = (b.captured != nil ? 1 : 0)
            return aVal > bVal
        }
    }

    static func minimax (board: inout ChessBoard, depth: Int, alpha: Int, beta: Int) -> Int {
        if depth == 0 {
            return evaluate (board: board)
        }

        let moves = generateMovesForSearch (board: &board)

        if moves.isEmpty {
            if GameState.isCheck (board: board) {
                return -99999 - depth
            }
            return 0
        }

        var alpha = alpha
        let ordered = orderMoves (moves)

        for move in ordered {
            board.makeMove (move)
            let score = -minimax (board: &board, depth: depth - 1, alpha: -beta, beta: -alpha)
            board.undoMove ()

            if score >= beta {
                return beta  
            }
            if score > alpha {
                alpha = score
            }
        }

        return alpha
    }

    static func evaluate (board: ChessBoard) -> Int {
        var score = 0

        for row in 0...7 {
            for col in 0...7 {
                guard let piece = board.board [row][col] else { continue }
                let value = (pieceValues [piece.type] ?? 0) + pieceSquareValue (piece: piece, row: row, col: col)

                if piece.isWhite == board.whiteToMove {
                    score += value
                } else {
                    score -= value
                }
            }
        }

        return score
    }
}
