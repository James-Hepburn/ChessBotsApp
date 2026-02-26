enum PieceType {
    case pawn, rook, knight, bishop, queen, king
}

struct ChessPiece {
    let type: PieceType
    let isWhite: Bool
    let hasMoved: Bool
    
    var symbol: String {
        switch type {
            case .pawn: return isWhite ? "♙" : "♟"
            case .rook: return isWhite ? "♖" : "♜"
            case .knight: return isWhite ? "♘" : "♞"
            case .bishop: return isWhite ? "♗" : "♝"
            case .queen: return isWhite ? "♕" : "♛"
            case .king: return isWhite ? "♔" : "♚"
        }
    }
}
