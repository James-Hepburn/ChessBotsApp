import SwiftUI

enum Difficulty {
    case easy, medium, hard
}

struct ContentView: View {
    @State private var difficulty: Difficulty?
    @State private var showGame = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea ()
                
                VStack {
                    Text ("Select a Difficulty")
                        .font (.title.bold ())
                        .foregroundColor (Color.white)
                        .padding (.bottom, 50)
                    
                    difficultyButton ("Easy", difficulty: .easy)
                    difficultyButton ("Medium", difficulty: .medium)
                    difficultyButton ("Hard", difficulty: .hard)
                }
                .padding ()
            }
            .navigationDestination (isPresented: $showGame) {
                ChessGameView (difficulty: difficulty ?? .easy)
            }
        }
    }
    
    func difficultyButton (_ title: String, difficulty: Difficulty) -> some View {
        Button (title) {
            self.difficulty = difficulty
            showGame = true
        }
        .frame (width: 120, height: 60)
        .background (Color.purple)
        .foregroundColor (Color.white)
        .cornerRadius (10)
        .font (.title2.bold ())
        .padding ()
    }
}

#Preview {
    ContentView ()
}
