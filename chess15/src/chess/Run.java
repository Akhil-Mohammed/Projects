//Yara Hanafi, Akhil Mohammed
package chess;

import java.util.ArrayList;
import java.util.Scanner;

public class Run {

    static int currentplayer = 1;
    static boolean Enpassante = false;
    static boolean castle = false;

    public static void Run() {
        boolean proceed = true;
        boolean draw = false;
        String input;
        int startRow;
        int finalRow;
        int startColumn;
        int finalColumn;


        while (proceed) {
            if(currentplayer == 1) {
                System.out.println();
                Scanner sc = new Scanner(System.in);
                System.out.println("White's move: ");
                input = sc.nextLine();
            } else {
                System.out.println();
                Scanner sc = new Scanner(System.in);
                System.out.println("Black's move: ");
                input = sc.nextLine();
            }

            if(draw == true){
                if (!input.equals("draw")){
                    System.out.println("Illegal move, try again");
                    continue;
                }
                return;
            }

            if(input.equals("resign")){
                if(currentplayer == 1){
                    System.out.println("Black wins");
                } else {
                    System.out.println("White wins");
                }
                return;
            }
            Piece curr;
            if(input.length() == 5){
                startColumn = Board.readcolumn(input.substring(0,1));
                startRow = Board.readrow(input.substring(1,2));
                curr = Board.pieceAtLocation(startRow, startColumn);

                finalColumn = Board.readcolumn(input.substring(3,4));
                finalRow = Board.readrow(input.substring(4,5));

                if(!Check(curr.getColor())){
                    if((curr.getboardName().equals("wp ") || curr.getboardName().equals("bp ")) &&
                            curr.canMove(finalRow,finalColumn)){ //if pawn
                        if(Promotion(curr,finalRow)){
                            Board.removePiece(curr);
                            Piece f = promopiece(finalRow, finalColumn,curr.getColor(),"Q");
                            Board.placePiece(f, finalRow, finalColumn);
                            Board.displayBoard();
                        } else {
                            curr.movePiece(finalRow, finalColumn);
                            System.out.println("here");
                            if(Enpassante == true){
                                System.out.println("here2");
                                Board.removePiece(curr);
                                Enpassante = false;
                            }
                            Board.displayBoard();
                        }
                    } else if(curr.getboardName().equals("wK ") || curr.getboardName().equals("bK ")){
                        if(Castling(input)){
                            castle = true;
                            curr.movePiece(finalRow, finalColumn);
                            Board.displayBoard();
                            castle = false;
                        } else if(curr.canMove(finalRow,finalColumn)){
                            curr.movePiece(finalRow, finalColumn);
                            Board.displayBoard();
                        }

                    } else{
                        if(curr.canMove(finalRow,finalColumn)) {
                            curr.movePiece(finalRow, finalColumn);
                            Board.displayBoard();
                        }
                    }
                } else {
                    if(Checkmate(curr.getColor())){
                        System.out.println("CheckMate");
                        return;
                    }
                    System.out.println("Illegal move, try again");
                    continue;
                }
            } else if(input.length() == 7){
                startColumn = Board.readcolumn(input.substring(0,1));
                startRow = Board.readrow(input.substring(1,2));
                curr = Board.pieceAtLocation(startRow, startColumn);
                finalColumn = Board.readcolumn(input.substring(3,4));
                finalRow = Board.readrow(input.substring(4,5));
                String letter = input.substring(6);
                if(curr.canMove(finalRow,finalColumn) && !Checkmate(curr.getColor())){

                    if(curr.getboardName().equals("wp ") || curr.getboardName().equals("bp ")){
                        if(Promotion(curr,finalRow)){
                            Board.removePiece(curr);
                            Piece f = promopiece(finalRow, finalColumn,curr.getColor(),letter);
                            Board.placePiece(f, finalRow, finalColumn);
                            Board.displayBoard();
                        } else {
                            System.out.println("Illegal move, try again");
                            continue;
                        }
                    } else {
                        System.out.println("Illegal move, try again");
                        continue;
                    }
                } else {
                    if(Checkmate(curr.getColor())){
                        System.out.println("CheckMate");
                        return;
                    }
                    System.out.println("Illegal move, try again");
                    continue;
                }
            } else {
                String[] s = input.split(" ");
                if (s[2].equals("draw?")) {
                    draw = true;
                }
            }

            if(currentplayer ==1 ){
                currentplayer = 0;
            } else{
                currentplayer =1;
            }
        }

    }







    public static int getCurrentPlayer() {
        return currentplayer;
    }




    public static King whiteking= (King) Board.pieceAtLocation(7,4);
    public static King blackking= (King) Board.pieceAtLocation(0,4);
    public static King kingPiece = null; //initially having no value to it, as it hasn't been associated with any king piece yet
    public static ArrayList<Piece> chessPieces = null;

    public static boolean Castling(String temp) {
        Rook whiteright = (Rook) Board.pieceAtLocation(7,7);
        Rook whiteleft = (Rook) Board.pieceAtLocation(7,0);
        Rook blackright= (Rook) Board.pieceAtLocation(0,7);
        Rook blackleft = (Rook) Board.pieceAtLocation(0,0);

        if (Run.getCurrentPlayer() == 1) //if white {
        {
            if (!Board.pieceAtLocation(7,4).getboardName().equals("wK "))
                return false;
            if (!Board.pieceAtLocation(7,7).getboardName().equals("wR ") &&
                    !Board.pieceAtLocation(7,0).getboardName().equals("wR "))
                return false;

            if (whiteking.hasMoved == true) //The King must not have moved at all. hasmove method = false
                return false;

            if (Run.Check(whiteking.getColor()) == true)  //The King is in check
                return false;


                //The Rook must not have moved at all. hasmove method = false
            else if (whiteright.hasMoved == true && whiteleft.hasMoved == true) // left and right rooks for white
                return false;


            int r = whiteking.getRow();
            int c = whiteking.getColumn();


            ArrayList<Piece> allblackpieces = Chess.BlackPieces;
            ArrayList<Piece> allwhitepieces = Chess.WhitePieces;


            if (temp.equals("e1 g1")) {
                if (Board.pieceAtLocation(7,7).getboardName().equals("wR "))
                    whiteright= (Rook) Board.pieceAtLocation(7,7);
                else
                    return false;

                if (whiteright.hasMoved==true)
                    return false;

                if (whiteright.hasMoved == false) {  //if the white rook hasn't moved from its original position
                    //then it proceeds with castling. if it has moved, it returns false and does not castle

                    int i = 7;
                    int j = 5;
                    while (j < 7) {
                        if (!Board.isEmpty(i,j)) {
                            return false;

                        }else{
                            j++;
                        }

                    }
                    int k = 4 + 2; //King moves 2 spaces to the right from original position column 4
                    whiteking.movePiece(7, k);
                    whiteright.movePiece(7, k - 1); //rook moves one space to left of king's new position

                }
                for (Piece p1 : allblackpieces) //if castling causes the white King to be immediately placed in check
                // you must not allow it
                {
                    if (p1.canMove(r, c + 2) || p1.canMove(r,c+1))
                        return false;
                }

                return true;
            }


            if(temp.equals("e1 c1")) {

                if (Board.pieceAtLocation(7,0).getboardName().equals("wR "))
                    whiteleft= (Rook) Board.pieceAtLocation(7,0);
                else
                    return false;

                if (whiteleft.hasMoved==true)
                    return false;

                if (whiteleft.hasMoved == false) {

                    int i = 7;
                    int j = 3;
                    while (j > 0) {
                        if (!Board.isEmpty(i,j))
                            return false;

                        else
                            j--;

                    }
                    int k = 2; //two spaces to the left from king's original column 4
                    whiteking.movePiece(i, k);
                    whiteleft.movePiece(i, k + 1);  //rook moves one space to the right of king's new position
                }

                for (Piece p1 : allblackpieces) //if castling causes the white King to be immediately placed in check
                // you must not allow it
                {
                    if (p1.canMove(r, c - 2) || p1.canMove(r, c-1)) //not sure if to include   ||
                        return false;
                }
                return true;
            }


        }



        if (Run.getCurrentPlayer() == 0)  //if black
        {
            if (blackking.hasMoved == true) {
                return false;
            }
            if (Run.Check(blackking.getColor()) == true)  //The black King is in check
                return false;

            else if (blackleft.hasMoved == true && blackright.hasMoved == true) //left and right rooks for black
                return false;

            int r2 = blackking.getRow();   //black row
            int c2 = blackking.getColumn();   //black column
            ArrayList<Piece> allwhitepieces = Chess.WhitePieces;

            if (temp.equals("e8 g8")) {
                if (Board.pieceAtLocation(0,7).getboardName().equals("bR "))
                    blackright= (Rook) Board.pieceAtLocation(0,7);
                else
                    return false;

                if (blackright.hasMoved==true)
                    return false;

                if (blackright.hasMoved == false) {
                    int i = 0;
                    int j = 5;
                    while (j < 7) {
                        if (!Board.isEmpty(i,j))
                            return false;

                        else
                            j++;

                    }
                    int k = 6; //King moves 2 spaces to the right from original position column 4
                    blackking.movePiece(0, k);
                    blackright.movePiece(0, k - 1);   //rook moves one space to left of king's new position
                }

                for (Piece p1 : allwhitepieces)
                //if castling causes the black King to be immediately placed in check
                // you must not allow it
                {
                    if (p1.canMove(r2, c2 + 2)|| p1.canMove(r2, c2+1)) {
                        blackking.movePiece(0, 4);
                        blackright.movePiece(0,7);
                        return false;
                    }
                }
                return true;

            }

            if (temp.equals("e8 c8")) {

                if (blackleft.hasMoved==true)
                    return false;

                if (blackleft.hasMoved == false) {

                    int i = 0;
                    int j = 3;
                    while (j > 0) {

                        if (!Board.isEmpty(i,j))
                            return false;

                        else
                            j--;

                    }
                    int k = 2; //two spaces to the left from king's original column 4
                    whiteking.movePiece(i, k);
                    whiteleft.movePiece(i, k + 1);  //rook moves one space to the right of king's new position

                }

                for (Piece p1 : allwhitepieces)
                //if castling causes the black King to be immediately placed in check
                // you must not allow it
                {
                    if (p1.canMove(r2, c2 - 2) ||p1.canMove(r2,c2-1)) {
                        blackking.movePiece(0, 4);
                        blackleft.movePiece(0, 0);
                        return false;
                    }
                }
                return true;
            }

        }

        return false;
    }

    public static boolean CheckExtension(int color) {   //Checking to see if you can move other same color pieces of king
        // to help king get out of check, and notify player if they make an illegal move that doesn't take king out of
        // check. Checkmate method calls on this method

        if (Check(color) == false)
            return false;

        else if (Check(color) == true) {

            if (color == 1) //white king
                chessPieces = Chess.WhitePieces;
            if (color == 0) //black king
                chessPieces = Chess.BlackPieces;


            for (int i = 0; i < 8; i++) {
                for (int j = 0; j < 8; j++) {
                    for (Piece p : chessPieces) {
                        int prevrow = p.getRow();
                        int prevcol = p.getColumn();
                        Piece temp = Board.pieceAtLocation(i, j);

                        if (p.canMove(i, j) == true) ;
                        {

                            p.movePiece(i, j);

                            if (Check(color) == false)
                                return false;

                                //if the user input is not equal to moving the king out of check
                            else if (Check(color) == true) {
                                p.movePiece(prevrow, prevcol);

                                if (temp != null) {
                                    Board.placePiece(temp, i, j);
                                    temp.hasMoved = true;
                                }
                                System.out.println("Illegal Move. Try again");

                            }
                        }
                    }
                }
            }
            return true;
        }

        return false;
    }

    public static boolean Check(int color) { //verifying if king is in check or not


        if (color == 1) // 1 being white, revolving around the white king piece
        {
            kingPiece = whiteking;
            chessPieces = Chess.BlackPieces;
        } else if (color == 0)  //0 being black, revolving around the black king piece
        {
            kingPiece = blackking;
            chessPieces = Chess.WhitePieces;
        }

        int r = kingPiece.getRow();    //storing location of the king piece row into object
        int c = kingPiece.getColumn(); //storing location of king piece row into object

        for (Piece p : chessPieces) {
            if (p.canMove(r, c))
                return true;
        }


        return false;
    }

    public static boolean Checkmate(int color) {
        if (!Check(color)== false)
            return false;

        if (Check(color) == true && color == 1) //white king
        {
            kingPiece = whiteking;
            chessPieces = Chess.WhitePieces;
        }

        if (Check(color) == true && color == 0) {

            kingPiece = blackking;
            chessPieces = Chess.BlackPieces;
        }

        int r = kingPiece.getRow();  //king row
        int c = kingPiece.getColumn();  //king column

        //8 different movements king can do to move out of checkmate
        //Can king move one step east, west, north, south, northeast, northwest, southwest, southeast

        //one step east, west, north, south, northeast, northwest, southeast, or southwest
        if
        ((kingPiece.canMove(r, c + 1))
                || (kingPiece.canMove(r, c - 1))
                || (kingPiece.canMove(r - 1, c))
                || (kingPiece.canMove(r + 1, c))
                || (kingPiece.canMove(r - 1, c + 1))
                || (kingPiece.canMove(r - 1, c - 1))
                || (kingPiece.canMove(r + 1, c + 1))
                || (kingPiece.canMove(r + 1, c - 1))) {
            return false;
        }
        //can another piece move to stop king from being in check
        //if that piece moves, does it create a new opening where the king is automatically in check still

        if (CheckExtension(color) == true)   //if true, then checkmate. if false, then not checkmate
            return true;
        return false;

    }

    public static void Kingmove2(int color, int row, int column) {

        //making sure that you don't move a piece that would put
        //your king in automatic check

        if (color == 1)
            //kingPiece=whiteking;
            chessPieces = Chess.WhitePieces;

        if (color == 0)

            //kingPiece=blackking;
            chessPieces = Chess.BlackPieces;

        for (Piece p : chessPieces) {

            int prevrow = p.getRow();
            int prevcol = p.getColumn();
            Piece temp = Board.pieceAtLocation(row, column);

            if (p.canMove(row, column)) {

                p.movePiece(row, column);

                if (Check(color) == true) {
                    p.movePiece(prevrow, prevcol);

                    if (temp != null) {
                        Board.placePiece(temp, row, column);
                        temp.hasMoved = true;
                    }
                    System.out.println("Illegal Move. Try again");
                }
            }
        }
    }


    public static boolean Promotion(Piece p, int row) {
        if (p.getColor() == 1) {
            if (row == 0) {
                return true;
            }
            return false;
        }

        if (p.getColor() == 0) {
            if (row == 7) {
                return true;
            }
            return false;

        }
        return false;
    }

    public static Piece promopiece(int row, int column, int color, String letter){
        if(color == 1) {
            if (letter.equals("R")) {
                return new Rook(color, row, column, "wR ");
            } else if (letter.equals("N")) {
                return new Knight(color, row, column,"wN ");
            } else if (letter.equals("B")) {
                return new Bishop(color, row, column,"wB " );
            } else if (letter.equals("Q")) {
                return new Bishop(color, row, column, "wQ ");
            } else if (letter.equals("K")) {
                return new Bishop(color, row, column,"wK ");
            } else if (letter.equals("p")) {
                return new Bishop(color, row, column, "wp ");
            }
        }

        if(color == 0){
            if (letter.equals("R")) {
                return new Rook(color, row, column, "bR ");
            } else if (letter.equals("N")) {
                return new Knight(color, row, column,"bN ");
            } else if (letter.equals("B")) {
                return new Bishop(color, row, column,"bB " );
            } else if (letter.equals("Q")) {
                return new Bishop(color, row, column, "bQ ");
            } else if (letter.equals("K")) {
                return new Bishop(color, row, column,"bK ");
            } else if (letter.equals("p")) {
                return new Bishop(color, row, column, "bp ");
            }
        }
        return null;
    }


    public boolean EndGame() {
        if (Checkmate(1) || Checkmate(0)) {
            System.out.println("Checkmate");
            return true;
        } else
            return false;
    }
}