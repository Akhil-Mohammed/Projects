//Yara Hanafi, Akhil Mohammed
package chess;

public class Rook extends Piece{
    public Rook(int color, int row, int column, String boardName){
        super(color, row, column, boardName);
    }

    public boolean canMove(int row, int column){
        if(canMove2(row, column)){
            return RookMove(row, column);
        }
        return false;
    }


    public boolean RookMove(int row, int column){
        return canMoveStraight(row, column);
    }
}
