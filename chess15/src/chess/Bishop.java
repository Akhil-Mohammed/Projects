//Yara Hanafi, Akhil Mohammed
package chess;

public class Bishop extends Piece{
    public Bishop(int color, int row, int column, String boardName){
        super(color, row, column, boardName);
    }

    public boolean canMove(int row, int column){
        if(canMove2(row, column)){
            return BishopMove(row,column);
        }
        return false;
    }

    private boolean BishopMove(int row, int column){
        return canMoveDiagonal(row, column);

    }
}
