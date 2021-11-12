//Yara Hanafi, Akhil Mohammed
package chess;


public class King extends Piece {
    public King(int color, int row, int column, String boardName) {
        super(color, row, column, boardName);
    }

    public boolean canMove(int row, int column) {
        if (canMove2(row, column)) {
            return KingMove(row, column);
        }
        return false;
    }

    private boolean KingMove(int row, int column) {
        int absRow = Math.abs(row - this.getRow());
        int absColumn = Math.abs(column - this.getColumn());

        if (absRow <= 1 && absColumn <= 1) {
            if (absRow == 0 && absColumn == 0) {
                return false;
            }
            return true;
        }
        return false;
    }
}









