//Yara Hanafi, Akhil Mohammed
package chess;

public class Knight extends Piece{
    public Knight(int color, int row, int column, String boardName){
        super(color, row, column, boardName);
    }

    public boolean canMove(int row, int column){
        if(canMove2(row, column)){
            return KnightMove(row, column);
        }
        return false;
    }


    public boolean KnightMove(int row, int column){
        if (Math.abs(this.getRow() - row) == 2 && Math.abs(this.getColumn() - column) == 1) {
            return true;
        }

        if (Math.abs(this.getRow() - row) == 1 && Math.abs(this.getColumn() - column) == 2) {
            return true;
        }
        return false;
    }
}
