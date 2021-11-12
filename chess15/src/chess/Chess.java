//Yara Hanafi, Akhil Mohammed
package chess;


import java.util.ArrayList;

public class Chess {
	public static ArrayList<Piece> BlackPieces = new ArrayList<Piece>();
	public static ArrayList<Piece> WhitePieces = new ArrayList<Piece>();




	public static void main(String[] args) {
		BlackPieces.add(new Rook(0,0,0,"bR "));
		BlackPieces.add(new Knight(0,0,1,"bN "));
		BlackPieces.add(new Bishop(0,0,2,"bB "));
		BlackPieces.add(new Queen(0,0,3,"bQ "));
		BlackPieces.add(new King(0,0,4,"bK "));
		BlackPieces.add(new Bishop(0,0,5,"bB "));
		BlackPieces.add(new Knight(0,0,6,"bN "));
		BlackPieces.add(new Rook(0,0,7,"bR "));
		BlackPieces.add(new Pawn(0,1,0,"bp "));
		BlackPieces.add(new Pawn(0,1,1,"bp "));
		BlackPieces.add(new Pawn(0,1,2,"bp "));
		BlackPieces.add(new Pawn(0,1,3,"bp "));
		BlackPieces.add(new Pawn(0,1,4,"bp "));
		BlackPieces.add(new Pawn(0,1,5,"bp "));
		BlackPieces.add(new Pawn(0,1,6,"bp "));
		BlackPieces.add(new Pawn(0,1,7,"bp "));

		WhitePieces.add(new Rook(1,7,0,"wR "));
		WhitePieces.add(new Knight(1,7,1,"wN "));
		WhitePieces.add(new Bishop(1,7,2,"wB "));
		WhitePieces.add(new Queen(1,7,3,"wQ "));
		WhitePieces.add(new King(1,7,4,"wK "));
		WhitePieces.add(new Bishop(1,7,5,"wB "));
		WhitePieces.add(new Knight(1,7,6,"wN "));
		WhitePieces.add(new Rook(1,7,7,"wR "));
		WhitePieces.add(new Pawn(1,6,0,"wp "));
		WhitePieces.add(new Pawn(1,6,1,"wp "));
		WhitePieces.add(new Pawn(1,6,2,"wp "));
		WhitePieces.add(new Pawn(1,6,3,"wp "));
		WhitePieces.add(new Pawn(1,6,4,"wp "));
		WhitePieces.add(new Pawn(1,6,5,"wp "));
		WhitePieces.add(new Pawn(1,6,6,"wp "));
		WhitePieces.add(new Pawn(1,6,7,"wp "));

		Board.displayBoard();
		Run.Run();

	}

}
