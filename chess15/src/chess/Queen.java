//Yara Hanafi, Akhil Mohammed
package chess;

public class Queen extends Piece{
    public Queen(int color, int row, int column, String boardName){
        super(color, row, column, boardName);
    }

    public boolean canMove(int row, int column){
        if(canMove2(row, column)){
            return QueenMove(row, column);
        }
        return false;
    }

    public boolean QueenMove(int row, int column){
        if(canMoveStraight(row, column) || canMoveDiagonal(row, column)){
            return true;
        }
        return false;
    }

}
