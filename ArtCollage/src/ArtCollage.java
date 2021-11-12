/*************************************************************************
 *  Compilation:  javac ArtCollage.java
 *  Execution:    java ArtCollage
 *
 *  @author:
 *
 *************************************************************************/

import java.awt.Color;

public class ArtCollage {

    // The original picture
    private Picture original;

    // The collage picture
    private Picture collage;

    // The collage Picture consists of collageDimension X collageDimension tiles
    private int collageDimension;

    // A tile consists of tileDimension X tileDimension pixels
    private int tileDimension;
    
    /*
     * One-argument Constructor
     * 1. set default values of collageDimension to 4 and tileDimension to 100
     * 2. initializes original with the filename image
     * 3. initializes collage as a Picture of tileDimension*collageDimension x tileDimension*collageDimension, 
     *    where each pixel is black (see all constructors for the Picture class).
     * 4. update collage to be a scaled version of original (see scaling filter on Week 9 slides)
     *
     * @param filename the image filename
     */
    public ArtCollage (String filename) {

    collageDimension = 4;
        tileDimension = 100;
        original = new Picture(filename);
        int dimension = tileDimension * collageDimension;
        collage = new Picture(dimension, dimension);
        for (int tcol = 0; tcol < dimension; tcol++) {
            for (int trow = 0; trow < dimension; trow++) {
                int scol = tcol * original.width() / dimension;
                int srow = trow * original.height() / dimension;
                Color color = original.get(scol, srow);
                collage.set(tcol, trow, color);
            }
        }

    }

    /*
     * Three-arguments Constructor
     * 1. set default values of collageDimension to cd and tileDimension to td
     * 2. initializes original with the filename image
     * 3. initializes collage as a Picture of tileDimension*collageDimension x tileDimension*collageDimension, 
     *    where each pixel is black (see all constructors for the Picture class).
     * 4. update collage to be a scaled version of original (see scaling filter on Week 9 slides)
     *
     * @param filename the image filename
     */
    public ArtCollage (String filename, int td, int cd) {

    collageDimension = cd;
        tileDimension = td;
        original = new Picture(filename);
        int dimension = tileDimension * collageDimension;
        collage = new Picture(dimension, dimension);
        for (int mcol = 0; mcol < dimension; mcol++) {
            for (int mrow = 0; mrow < dimension; mrow++) {
                int wcol = mcol * original.width() / dimension;
                int wrow = mrow * original.height() / dimension;
                Color color = original.get(wcol, wrow);
                collage.set(mcol, mrow, color);
            }
        }
    }

    /*
     * Returns the collageDimension instance variable
     *
     * @return collageDimension
     */
    public int getCollageDimension() {

    return collageDimension;
    }

    /*
     * Returns the tileDimension instance variable
     *
     * @return tileDimension
     */
    public int getTileDimension() {

    return tileDimension;
    }

    /*
     * Returns original instance variable
     *
     * @return original
     */
    public Picture getOriginalPicture() {

    return original;
    }

    /*
     * Returns collage instance variable
     *
     * @return collage
     */
    public Picture getCollagePicture() {

    return collage;
    }
    
    /*
     * Display the original image
     * Assumes that original has been initialized
     */
    public void showOriginalPicture() {

    this.original.show();
    }

    /*
     * Display the collage image
     * Assumes that collage has been initialized
     */
    public void showCollagePicture() {

    collage.show();
    }

    /*
     * Replaces the tile at collageCol,collageRow with the image from filename
     * Tile (0,0) is the upper leftmost tile
     *
     * @param filename image to replace tile
     * @param collageCol tile column
     * @param collageRow tile row
     */
    public void replaceTile (String filename,  int collageCol, int collageRow) {

    int colDimension = collageCol * tileDimension;
        int rowDimension = collageRow * tileDimension;
        Picture source = new Picture(filename);
        Picture ScalePhoto = new Picture(tileDimension, tileDimension);
        for (int mcol = 0; mcol < tileDimension; mcol++) {
            for (int mrow = 0; mrow < tileDimension; mrow++) {
                int wcol = mcol * source.width() / tileDimension;
                int wrow = mrow * source.height() / tileDimension;
                Color color = source.get(wcol, wrow);
                ScalePhoto.set(mcol, mrow, color);
            }
        }
        for (int zcol = 0; zcol < tileDimension; zcol ++) {
            for (int zrow = 0; zrow < tileDimension; zrow ++) {
                Color color = ScalePhoto.get(zcol, zrow);
                collage.set(zcol+colDimension, zrow+rowDimension, color);
            }
        }
    }
    
    /*
     * Makes a collage of tiles from original Picture
     * original will have collageDimension x collageDimension tiles, each tile
     * has tileDimension X tileDimension pixels
     */
    public void makeCollage () {

    Picture tile = new Picture (tileDimension, tileDimension);
        for (int mcol = 0; mcol < tileDimension; mcol++) {
            for (int mrow = 0; mrow < tileDimension; mrow++) {
                int wcol = mcol * original.width() / tileDimension;
                int wrow = mrow * original.height() / tileDimension;
                Color color = original.get(wcol, wrow);
                tile.set(mcol, mrow, color);
            }
        }
        for (int zcol = 0; zcol < collage.height(); zcol++) {
            for (int zrow = 0; zrow < collage.width(); zrow++) {
                int wcol = zcol % tileDimension;
                int wrow = zrow % tileDimension;
                Color color = tile.get(wcol, wrow);
                collage.set(zcol, zrow, color);
            }
        }
    }

    /*
     * Colorizes the tile at (collageCol, collageRow) with component 
     * (see Week 9 slides, the code for color separation is at the 
     *  book's website)
     *
     * @param component is either red, blue or green
     * @param collageCol tile column
     * @param collageRow tile row
     */
    public void colorizeTile (String component,  int collageCol, int collageRow) {

     int colDimension = collageCol * tileDimension;
        int rowDimension = collageRow * tileDimension;
        for (int zcol = colDimension; zcol < colDimension+tileDimension; zcol++) {
            for (int zrow = rowDimension; zrow < rowDimension+tileDimension; zrow++) {
                Color color = collage.get(zcol, zrow);
                int r = color.getRed();
                int g = color.getGreen();
                int b = color.getBlue();
                Color colorize;
                if (component.compareTo("red")==0) {
                    colorize = new Color(r, 0, 0);
                }
                else if (component.compareTo("green")==0) {
                    colorize = new Color(0, g, 0);;
                }
                else {
                    colorize = new Color(0, 0, b);
                }
                collage.set(zcol, zrow, colorize);
            }
        }
    }

    /*
     * Greyscale tile at (collageCol, collageRow)
     * (see Week 9 slides, the code for luminance is at the book's website)
     *
     * @param collageCol tile column
     * @param collageRow tile row
     */

    public void greyscaleTile (int collageCol, int collageRow) {

    int colDimension = collageCol * tileDimension;
        int rowDimension = collageRow * tileDimension;
        for (int zcol = colDimension; zcol < colDimension+tileDimension; zcol++) {
            for (int zrow = rowDimension; zrow < rowDimension+tileDimension; zrow++) {
                Color color = collage.get(zcol, zrow);
                Color gray = Luminance.toGray(color);
                collage.set(zcol, zrow, gray);
            }
        }
    }




    // Test client 
    public static void main (String[] args) {

    }
}





