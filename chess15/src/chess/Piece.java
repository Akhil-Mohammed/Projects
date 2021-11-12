//Yara Hanafi, Akhil Mohammed
package chess;

public class Piece {
    int row;
    int column;
    int color;
    String boardName;
    boolean hasMoved;

    //Constructor for Piece
    public Piece(int color, int row, int column, String boardName) {
        this.color = color;
        this.hasMoved = false;
        this.row = row;
        this.column = column;
        this.boardName = boardName;
    }

    //Method to return the String name of piece for board
    public String getboardName() {
        return boardName;
    }

    //Gets row index
    public int getRow() {
        return row;
    }

    //Gets column index
    public int getColumn() {
        return column;
    }

    //Gets color where black is 0 and white is 1
    public int getColor() {
        return color;
    }


    //check if piece can move to desired location -- generic usage(each class has its own method)
    public boolean canMove(int row, int column) {
        return canMove2(row, column);
    }

    //Method to be called by canMove method
    public boolean canMove2(int row, int column) {
        if (Board.isInLimits(row, column)) {
            Piece current = Board.pieceAtLocation(row, column);

            if (current == null) {
                return true;
            } else if (current.getColor() != this.color) {
                return true;
            }
        }
        return false;
    }

    //method used to move the chess piece to specified location and
    // removes any enemy pieces at that location if present
    public void movePiece(int row, int column) {
        if(canMove2(row,column)) {
            Board.removePiece(this);

            Piece enemy = Board.pieceAtLocation(row, column);
            if (enemy != null) {
                Board.removePiece(enemy);
            }

            Board.placePiece(this, row, column);
            this.hasMoved = true;
        }
    }


    //Method to see if a piece can move straight
    boolean canMoveStraight(int row, int column) {
        int currentRow = this.getRow();
        int currentColumn = this.getColumn();

        int small;
        int large;

        //for horizontal movement
        if (currentRow == row) {
            if (currentColumn > column) {
                small = column;
                large = currentColumn;
            } else if (column > currentColumn) {
                small = currentColumn;
                large = column;
            } else {
                return false;
            }

            // Find if there is any piece between target location and current piece
            for (int i = small + 1; i < large; i++) {
                if (Board.pieceAtLocation(row, i) != null) {
                    return false;
                }
            }
            return true;
        }


        // for vertical movement
        if (currentColumn == column) {
            if (currentRow > row) {
                small = row;
                large = currentRow;
            } else if (row > currentRow) {
                small = currentRow;
                large = row;
            } else {
                return false;
            }

            // Find if there is any piece between target location and current piece
            for (int j = small + 1; j < large; j++) {
                if (Board.pieceAtLocation(j, column) != null) {
                    return false;
                }
            }
            return true;
        }

        return false;
    }


    //Method to see if a piece can move Diagonal
    boolean canMoveDiagonal(int row, int column) {
        int currentRow = this.getRow();
        int currentColumn = this.getColumn();
        int Column;
        int compColumn;
        int smallRow ;
        int largeRow ;


        //check diagonal movement
        int rowTotal = Math.abs(row - currentRow);
        int columnTotal = Math.abs(column - currentColumn);

        if (rowTotal == columnTotal) {

            if(row < currentRow){
                smallRow = row;
                largeRow = currentRow;
                Column = column;
                compColumn = currentColumn;
            } else if(row > currentRow){
                smallRow = currentRow;
                largeRow = row;
                Column = currentColumn;
                compColumn = column;
            } else {
                return false;
            }

            if(compColumn< Column){
                // Find if there is any piece between target location and current piece
                int r = smallRow + 1;
                int c = Column - 1;
                while (r < largeRow ) {
                    if (Board.pieceAtLocation(r, c) != null) {
                        return false;
                    }
                    r++;
                    c--;
                }
            } else if(compColumn > Column){
                // Find if there is any piece between target location and current piece
                int r = smallRow + 1;
                int c = Column + 1;
                while (r < largeRow ) {
                    if (Board.pieceAtLocation(r, c) != null) {
                        return false;
                    }
                    r++;
                    c++;
                }
            } else {
                return false;
            }

            return true;
        }
        return false;
    }
}
