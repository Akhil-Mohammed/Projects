//Yara Hanafi, Akhil Mohammed
package chess;

import java.util.ArrayList;
import java.util.Objects;

public class Board {

    public static String[][] chessBoard = new String[9][9];

    //check whether position is within boundary
    public static boolean isInLimits(int row, int column){
        if (row<8 && row>=0 && column<8 && column>=0){
            return true;
        }
        return false;
    }

    //check if position is empty
    public static boolean isEmpty(int row, int column){
        if (chessBoard[row][column] == "   " || chessBoard[row][column]== "## ") {
            return true;
        }
        return false;
    }

    //Placing a piece into board at specified row & column
    public static void placePiece(Piece chessPiece,int row, int column){
        chessPiece.row = row;
        chessPiece.column = column;
        if(chessPiece.getColor() == 0){
            Chess.BlackPieces.add(chessPiece);
        } else if (chessPiece.getColor() ==1) {
            Chess.WhitePieces.add(chessPiece);
        }
    }

    //get the piece found in that position in board
    public static Piece pieceAtLocation(int row, int column){
        if(!isEmpty(row,column)) {
            String name = chessBoard[row][column];
            Piece t ;
            for (int i = 0; i < Chess.WhitePieces.size(); i++) {
                t = Chess.WhitePieces.get(i);
                if ((Objects.equals(t.getboardName(), name)) && (t.getRow()==row) && (t.getColumn()==column)){
                    return t;
                }
            }
            for (int j = 0; j < Chess.BlackPieces.size(); j++) {
                t = Chess.BlackPieces.get(j);
                if ((Objects.equals(t.getboardName(), name)) && (t.getRow()==row) && (t.getColumn()==column)){
                    return t;
                }
            }

        }
        return null;
    }

    //To print out board -- use after every new move
    public static void displayBoard() {
        setBoard();
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                if (chessBoard[i][j] == null) {
                    chessBoard[i][j] = "   ";
                }
                System.out.print(chessBoard[i][j]);
            }
            System.out.println();
        }
    }

    //method used by the displayBoard
    private static void setBoard() {
        chessBoard[8][0] = " a ";
        chessBoard[8][1] = " b ";
        chessBoard[8][2] = " c ";
        chessBoard[8][3] = " d ";
        chessBoard[8][4] = " e ";
        chessBoard[8][5] = " f ";
        chessBoard[8][6] = " g ";
        chessBoard[8][7] = " h ";

        chessBoard[0][8] = "8";
        chessBoard[1][8] = "7";
        chessBoard[2][8] = "6";
        chessBoard[3][8] = "5";
        chessBoard[4][8] = "4";
        chessBoard[5][8] = "3";
        chessBoard[6][8] = "2";
        chessBoard[7][8] = "1";

        for (int i = 0; i < 8; i++) {
            for (int j = 0; j < 8; j++) {
                if (i % 2 == 0) {
                    if (j % 2 == 0) {
                        chessBoard[i][j] = "   ";
                    } else {
                        chessBoard[i][j] = "## ";
                    }
                } else {
                    if (j % 2 == 0) {
                        chessBoard[i][j] = "## ";
                    } else {
                        chessBoard[i][j] = "   ";
                    }
                }
            }
        }

        Piece temp;
        for(int l =0; l<Chess.WhitePieces.size(); l++){
            temp = Chess.WhitePieces.get(l);
            chessBoard[temp.getRow()][temp.getColumn()] = temp.getboardName();
        }
        for(int k =0; k<Chess.BlackPieces.size(); k++){
            temp = Chess.BlackPieces.get(k);
            chessBoard[temp.getRow()][temp.getColumn()] = temp.getboardName();
        }
    }

    //To be used to convert the input column which is a letter into the correct column index
    public static int readcolumn(String letter) {
        if (letter.equals("a")) {
            return 0;
        } else if(letter.equals("b")) {
            return 1;
        }else if (letter.equals("c")) {
            return 2;
        } else if (letter.equals("d")) {
            return 3;
        } if (letter.equals("e")) {
            return 4;
        } else if (letter.equals("f")) {
            return 5;
        } else if (letter.equals("g")) {
            return 6;
        } else if (letter.equals("h")) {
            return 7;
        } else {
            return -1;
        }
    }

    //To be used to convert the input row which is a number into the correct row index
    public static int readrow(String num) {
        if (num.equals("8")) {
            return 0;
        } else if(num.equals("7")) {
            return 1;
        }else if (num.equals("6")) {
            return 2;
        } else if (num.equals("5")) {
            return 3;
        } if (num.equals("4")) {
            return 4;
        } else if (num.equals("3")) {
            return 5;
        } else if (num.equals("2")) {
            return 6;
        } else if (num.equals("1")) {
            return 7;
        } else {
            return -1;
        }
    }

        //To be used when removing a Piece from the board
        public static void removePiece (Piece removePiece){
            int color = removePiece.getColor();
            if(color == 0){
                Chess.BlackPieces.remove(removePiece);
            } else if (color==1) {
                Chess.WhitePieces.remove(removePiece);
            }
        }

}


