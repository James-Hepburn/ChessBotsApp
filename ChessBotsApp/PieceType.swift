enum PieceType {
    case pawn, rook, knight, bishop, queen, king
}

struct ChessPiece {
    let type: PieceType
    let isWhite: Bool
    let hasMoved: Bool
    
    var imageName: String {
        let color = isWhite ? "w" : "b"
        switch type {
        case .pawn: return "\(color)P"
        case .rook: return "\(color)R"
        case .knight: return "\(color)N"
        case .bishop: return "\(color)B"
        case .queen: return "\(color)Q"
        case .king: return "\(color)K"
        }
    }
}
