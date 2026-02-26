struct MoveGenerator {
    static func generatePseudoLegalMoves (board: ChessBoard) -> [Move] {
        var moves: [Move] = []

        for row in 0...7 {
            for col in 0...7 {
                guard let piece = board.board [row][col], piece.isWhite == board.whiteToMove else { continue }

                switch piece.type {
                case .pawn:
                    generatePawnMoves (board: board, row: row, col: col, piece: piece, moves: &moves)
                case .rook:
                    generateSlidingMoves (board: board, row: row, col: col, directions: [(1,0),(-1,0),(0,1),(0,-1)], piece: piece, moves: &moves)
                case .bishop:
                    generateSlidingMoves (board: board, row: row, col: col, directions: [(1,1),(1,-1),(-1,1),(-1,-1)], piece: piece, moves: &moves)
                case .queen:
                    generateSlidingMoves (board: board, row: row, col: col, directions: [(1,0),(-1,0),(0,1),(0,-1),(1,1),(1,-1),(-1,1),(-1,-1)], piece: piece, moves: &moves)
                case .knight:
                    generateKnightMoves (board: board, row: row, col: col, piece: piece, moves: &moves)
                case .king:
                    generateKingMoves (board: board, row: row, col: col, piece: piece, moves: &moves)
                }
            }
        }

        return moves
    }
    
    static func generatePawnMoves (board: ChessBoard, row: Int, col: Int, piece: ChessPiece, moves: inout [Move]) {
        let direction = piece.isWhite ? -1 : 1
        let startRow = piece.isWhite ? 6 : 1
        let oneStep = row + direction

        if oneStep >= 0 && oneStep < 8 {
            if board.board [oneStep][col] == nil {
                moves.append (Move (from: (row, col), to: (oneStep, col), captured: nil))
                let twoStep = row + 2 * direction
                
                if row == startRow && board.board [twoStep][col] == nil {
                    moves.append (Move (from: (row, col), to: (twoStep, col), captured: nil))
                }
            }
        }

        for dc in [-1, 1] {
            let newCol = col + dc
            
            if newCol >= 0 && newCol < 8 && oneStep >= 0 && oneStep < 8 {
                if let target = board.board [oneStep][newCol], target.isWhite != piece.isWhite {
                    moves.append (Move (from: (row, col), to: (oneStep, newCol), captured: target))
                }
            }
        }
        
        if let lastMove = board.moveHistory.last {
            let lastPiece = board.board [lastMove.to.0][lastMove.to.1]
            
            if let lastPiece = lastPiece, lastPiece.type == .pawn, abs (lastMove.to.0 - lastMove.from.0) == 2, lastMove.to.0 == row, abs (lastMove.to.1 - col) == 1 {
                let captureRow = row + direction
                let captureCol = lastMove.to.1
                moves.append (Move (from: (row, col), to: (captureRow, captureCol), captured: lastPiece, isEnPassant: true))
            }
        }
    }
    
    static func generateSlidingMoves (board: ChessBoard, row: Int, col: Int, directions: [(Int, Int)], piece: ChessPiece, moves: inout [Move]) {

        for (dr, dc) in directions {
            var r = row + dr
            var c = col + dc

            while r >= 0 && r < 8 && c >= 0 && c < 8 {
                if let target = board.board [r][c] {
                    if target.isWhite != piece.isWhite {
                        moves.append (Move (from: (row, col), to: (r, c), captured: target))
                    }

                    break
                }

                moves.append (Move (from: (row, col), to: (r, c), captured: nil))
                r += dr
                c += dc
            }
        }
    }
    
    static func generateKnightMoves (board: ChessBoard, row: Int, col: Int, piece: ChessPiece, moves: inout [Move]) {
        let offsets = [(-2,-1), (-2,1), (-1,-2), (-1,2), (1,-2), (1,2), (2,-1), (2,1)]

        for (dr, dc) in offsets {
            let r = row + dr
            let c = col + dc

            if r >= 0 && r < 8 && c >= 0 && c < 8 {
                if let target = board.board [r][c] {
                    if target.isWhite != piece.isWhite {
                        moves.append (Move (from: (row, col), to: (r, c), captured: target))
                    }
                } else {
                    moves.append (Move (from: (row, col), to: (r, c), captured: nil))
                }
            }
        }
    }
    
    static func generateKingMoves (board: ChessBoard, row: Int, col: Int, piece: ChessPiece, moves: inout [Move]) {
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }

                let r = row + dr
                let c = col + dc

                if r >= 0 && r < 8 && c >= 0 && c < 8 {
                    if let target = board.board [r][c] {
                        if target.isWhite != piece.isWhite {
                            moves.append (Move (from: (row, col), to: (r, c), captured: target))
                        }
                    } else {
                        moves.append (Move (from: (row, col), to: (r, c), captured: nil))
                    }
                }
            }
        }
    }
    
    static func generateCastlingMoves (board: ChessBoard, row: Int, piece: ChessPiece, moves: inout [Move]) {
        guard !piece.hasMoved else { return }

        let kingSquare = (row, 4)
        if AttackDetector.isSquareAttacked (board: board, square: kingSquare, byWhite: !piece.isWhite) { return }

        if let rook = board.board [row][7], !rook.hasMoved {
            if board.board [row][5] == nil && board.board [row][6] == nil {
                let passingSquare = (row, 5)
                let landingSquare = (row, 6)
                
                if !AttackDetector.isSquareAttacked (board: board, square: passingSquare, byWhite: !piece.isWhite) && !AttackDetector.isSquareAttacked (board: board, square: landingSquare, byWhite: !piece.isWhite) {
                    moves.append (Move (from: (row, 4), to: (row, 6), captured: nil, isCastling: true))
                }
            }
        }

        if let rook = board.board [row][0], !rook.hasMoved {
            if board.board [row][1] == nil && board.board [row][2] == nil && board.board [row][3] == nil {
                let passingSquare = (row, 3)
                let landingSquare = (row, 2)
                
                if !AttackDetector.isSquareAttacked (board: board, square: passingSquare, byWhite: !piece.isWhite) && !AttackDetector.isSquareAttacked (board: board, square: landingSquare, byWhite: !piece.isWhite) {
                    moves.append (Move (from: (row, 4), to: (row, 2), captured: nil, isCastling: true))
                }
            }
        }
    }
}
