//Yara Hanafi, Akhil Mohammed
package chess;

public class Pawn extends Piece{
    public Pawn(int color, int row, int column, String boardName){
        super(color, row, column, boardName);
    }

    public boolean canMove(int row, int column){
        if(canMove2(row, column)){
            return PawnMove(row, column);
        }
        return false;
    }


    public boolean PawnMove(int row, int column){
        Piece right = null;
        Piece left = null;
        int oneStep;
        int twoStep;

        Piece t = Board.pieceAtLocation(row, column);

        if (this.getColor() == 0){
            oneStep = 1;
            twoStep = 2;
        }
        else{
            oneStep = -1;
            twoStep = -2;
        }

       //for one-step movement
        if (row - this.getRow() == oneStep){
            if (column== this.getColumn() && t == null){
                return true;
            }

            if (Math.abs(this.getColumn() - column) == 1 && t != null){
                return true;
            }
        }
        // for two-step movement

        else if (hasMoved== false){
            if (row - this.getRow() == twoStep){
                if(column==0){
                    right = Board.pieceAtLocation(row,column+1);
                    if(right != null) {
                        if (color==1) {
                            if (right.getboardName().equals("bp ")) {
                                Run.Enpassante = true;
                            }
                        } else {
                            if (right.getboardName().equals("wp ")) {
                                Run.Enpassante = true;
                            }
                        }
                    }
                } else if (column == 7){
                    left = Board.pieceAtLocation(row,column-1);
                    if(left != null) {
                        if (color==1) {
                            if (left.getboardName().equals("bp ")) {
                                Run.Enpassante = true;
                            }
                        } else {
                            if (left.getboardName().equals("wp ")) {
                                Run.Enpassante = true;
                            }
                        }
                    }
                } else {
                    right = Board.pieceAtLocation(row,column+1);
                    left = Board.pieceAtLocation(row,column-1);
                    if(right != null) {
                        if (color==1) {
                            if (right.getboardName().equals("bp ")) {
                                System.out.println("he");
                                Run.Enpassante = true;
                            }
                        } else {
                            if (right.getboardName().equals("wp ")) {
                                System.out.println("h");
                                Run.Enpassante = true;
                            }
                        }
                    }
                    if (left != null){
                        if (color==1) {
                            if (left.getboardName().equals("bp ")) {
                                System.out.println("e");
                                Run.Enpassante = true;
                            }
                        } else {
                            if (left.getboardName().equals("wp ")) {
                                System.out.println("hrte");
                                Run.Enpassante = true;
                            }
                        }
                    }
                }

                Piece t2;
                if(twoStep == 2){
                    t2 = Board.pieceAtLocation(row-1, column);
                } else{
                    t2 = Board.pieceAtLocation(row+1, column);
                }

                if (column == this.getColumn() && t == null && t2 == null){
                    return true;
                }
            }
        }

        return false;
    }
}
