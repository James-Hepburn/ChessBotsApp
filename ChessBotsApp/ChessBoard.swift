struct ChessBoard {
    var board: [[ChessPiece?]] = Array (
        repeating: Array (repeating: nil, count: 8),
        count: 8
    )
    
    var whiteToMove = true

    var whiteKingPosition = (7, 4)
    var blackKingPosition = (0, 4)

    var moveHistory: [Move] = []
    
    init () {
        setupBoard ()
    }
    
    mutating func setupBoard () {
        board [0][0] = ChessPiece (type: .rook, isWhite: false, hasMoved: false)
        board [0][1] = ChessPiece (type: .knight, isWhite: false, hasMoved: false)
        board [0][2] = ChessPiece (type: .bishop, isWhite: false, hasMoved: false)
        board [0][3] = ChessPiece (type: .queen, isWhite: false, hasMoved: false)
        board [0][4] = ChessPiece (type: .king, isWhite: false, hasMoved: false)
        board [0][5] = ChessPiece (type: .bishop, isWhite: false, hasMoved: false)
        board [0][6] = ChessPiece (type: .knight, isWhite: false, hasMoved: false)
        board [0][7] = ChessPiece (type: .rook, isWhite: false, hasMoved: false)
        
        for i in 0...7 {
            board [6][i] = ChessPiece (type: .pawn, isWhite: true, hasMoved: false)
            board [1][i] = ChessPiece (type: .pawn, isWhite: false, hasMoved: false)
        }
        
        board [7][0] = ChessPiece (type: .rook, isWhite: true, hasMoved: false)
        board [7][1] = ChessPiece (type: .knight, isWhite: true, hasMoved: false)
        board [7][2] = ChessPiece (type: .bishop, isWhite: true, hasMoved: false)
        board [7][3] = ChessPiece (type: .queen, isWhite: true, hasMoved: false)
        board [7][4] = ChessPiece (type: .king, isWhite: true, hasMoved: false)
        board [7][5] = ChessPiece (type: .bishop, isWhite: true, hasMoved: false)
        board [7][6] = ChessPiece (type: .knight, isWhite: true, hasMoved: false)
        board [7][7] = ChessPiece (type: .rook, isWhite: true, hasMoved: false)
        
        whiteKingPosition = (7, 4)
        blackKingPosition = (0, 4)
        whiteToMove = true
    }
    
    mutating func movePiece (from: (Int, Int), to: (Int, Int)) {
        board [to.0][to.1] = board [from.0][from.1]
        board [from.0][from.1] = nil
    }
    
    mutating func makeMove (_ move: Move) {
        let piece = board [move.from.0][move.from.1]
        moveHistory.append (move)

        if var piece = piece {
            piece = ChessPiece (type: piece.type, isWhite: piece.isWhite, hasMoved: true)
            board [move.to.0][move.to.1] = piece
        }
        
        board [move.from.0][move.from.1] = nil

        if let piece = piece, piece.type == .king {
            if piece.isWhite {
                whiteKingPosition = move.to
            } else {
                blackKingPosition = move.to
            }
        }
        
        if move.isCastling {
            if move.to.1 == 6 {
                let rook = board [move.to.0][7]
                board [move.to.0][5] = ChessPiece (type: .rook, isWhite: rook!.isWhite, hasMoved: true)
                board [move.to.0][7] = nil
            } else if move.to.1 == 2 {
                let rook = board [move.to.0][0]
                board [move.to.0][3] = ChessPiece (type: .rook, isWhite: rook!.isWhite, hasMoved: true)
                board [move.to.0][0] = nil
            }
        }
        
        if move.isEnPassant {
            board [move.from.0][move.to.1] = nil
        }

        whiteToMove = !whiteToMove
    }

    mutating func undoMove () {
        guard let move = moveHistory.popLast () else { return }

        let piece = board [move.to.0][move.to.1]

        board [move.from.0][move.from.1] = piece
        board [move.to.0][move.to.1] = move.captured

        if let piece = piece, piece.type == .king {
            if piece.isWhite {
                whiteKingPosition = move.from
            } else {
                blackKingPosition = move.from
            }
        }
        
        if move.isCastling {
            if move.to.1 == 6 {
                let rook = board [move.to.0][5]
                board [move.to.0][7] = ChessPiece (type: .rook, isWhite: rook!.isWhite, hasMoved: false)
                board [move.to.0][5] = nil
            } else if move.to.1 == 2 {
                let rook = board [move.to.0][3]
                board [move.to.0][0] = ChessPiece (type: .rook, isWhite: rook!.isWhite, hasMoved: false)
                board [move.to.0][3] = nil
            }
        }
        
        if move.isEnPassant {
            board [move.from.0][move.to.1] = move.captured
            board [move.to.0][move.to.1] = nil
        }

        whiteToMove = !whiteToMove
    }
}
