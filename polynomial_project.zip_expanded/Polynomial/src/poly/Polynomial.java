package poly;

import java.io.IOException;
import java.util.Scanner;

/**
 * This class implements evaluate, add and multiply for polynomials.
 * 
 * @author runb-cs112
 *
 */
public class Polynomial {
	
	/**
	 * Reads a polynomial from an input stream (file or keyboard). The storage format
	 * of the polynomial is:
	 * <pre>
	 *     <coeff> <degree>
	 *     <coeff> <degree>
	 *     ...
	 *     <coeff> <degree>
	 * </pre>
	 * with the guarantee that degrees will be in descending order. For example:
	 * <pre>
	 *      4 5
	 *     -2 3
	 *      2 1
	 *      3 0
	 * </pre>
	 * which represents the polynomial:
	 * <pre>
	 *      4*x^5 - 2*x^3 + 2*x + 3 
	 * </pre>
	 * 
	 * @param sc Scanner from which a polynomial is to be read
	 * @throws IOException If there is any input error in reading the polynomial
	 * @return The polynomial linked list (front node) constructed from coefficients and
	 *         degrees read from scanner
	 */
	public static Node read(Scanner sc) 
	throws IOException {
		Node poly = null;
		while (sc.hasNextLine()) {
			Scanner scLine = new Scanner(sc.nextLine());
			poly = new Node(scLine.nextFloat(), scLine.nextInt(), poly);
			scLine.close();
		}
		return poly;
	}
	
	/**
	 * Returns the sum of two polynomials - DOES NOT change either of the input polynomials.
	 * The returned polynomial MUST have all new nodes. In other words, none of the nodes
	 * of the input polynomials can be in the result.
	 * 
	 * @param poly1 First input polynomial (front of polynomial linked list)
	 * @param poly2 Second input polynomial (front of polynomial linked list
	 * @return A new polynomial which is the sum of the input polynomials - the returned node
	 *         is the front of the result polynomial
	 */
	public static Node add(Node poly1, Node poly2) {
		/** COMPLETE THIS METHOD **/
		Node addsum = new Node(0,0,null);
		
		Node pointer = addsum;
		
		
		//while loop goes through the poly1 and poly2 lists
		while (poly1 !=null && poly2 !=null) {
			
			//
			if (poly1.term.degree > poly2.term.degree)
			{
				pointer.next=new Node(poly2.term.coeff, poly2.term.degree,null);
				poly2 = poly2.next;
				pointer=pointer.next;
			}//end if
			else if (poly1.term.degree < poly2.term.degree) {
				pointer.next= new Node (poly1.term.coeff, poly1.term.degree, null);
				poly1= poly1.next;
				pointer = pointer.next;
			}//end else if
			
			//if the numbers are equal- we have to play
			else if (poly1.term.degree == poly2.term.degree)
			{
				if (poly1.term.degree + poly2.term.coeff != 0)
				{
					pointer.next = new Node ( poly1.term.coeff +  poly2.term.coeff,  poly1.term.degree,  null);
					pointer = pointer.next;
				}//end if
				poly1=poly1.next;
				poly2=poly2.next;
				
			}//end elseif
		}//end while
		
		//what to do if the poly1 is empty- we can print poly2
		
		
		
		
		if (poly1==null) 
			{
			while (poly2 != null) {
				pointer.next= new Node (poly2.term.coeff, poly2.term.degree, null);
				
				poly2 = poly2.next;
				pointer=pointer.next;
			}//end while
			}//end if
		
		//do same if poly2 is empty linked list
		
				
		if (poly2 == null) 
		{
		while (poly1 != null) {
			pointer.next= new Node (poly1.term.coeff, poly1.term.degree, null);
			poly1 = poly1.next;
			pointer = pointer.next;
		}//end while
		} //end if
		
		
		// FOLLOWING LINE IS A PLACEHOLDER TO MAKE THIS METHOD COMPILE
		// CHANGE IT AS NEEDED FOR YOUR IMPLEMENTATION
		
		return addsum.next;
		
	}
	
	/**
	 * Returns the product of two polynomials - DOES NOT change either of the input polynomials.
	 * The returned polynomial MUST have all new nodes. In other words, none of the nodes
	 * of the input polynomials can be in the result.
	 * 
	 * @param poly1 First input polynomial (front of polynomial linked list)
	 * @param poly2 Second input polynomial (front of polynomial linked list)
	 * @return A new polynomial which is the product of the input polynomials - the returned node
	 *         is the front of the result polynomial
	 */
	public static Node multiply(Node poly1, Node poly2) {
		
		Node temporaryProduct = new Node ( 0 , 0 , null );
		
		Node product= new Node (0, -1, null);
		
		Node pointer = temporaryProduct;
		
		Node pointer2 = poly2;
		
		Node temporary;
		
		//getting all terms
		
		while (poly1 != null) {
			
			while (pointer2 != null) 
		{
				
				pointer.next= new Node ((poly1.term.coeff * pointer2.term.coeff), poly1.term.degree + pointer2.term.degree, null);
				pointer2 = pointer2.next;
				pointer = pointer.next;
				
		}//end while
			
			pointer2 = poly2;
			poly1= poly1.next;
			
		}//end while
		
		//Adding like terms
		pointer = temporaryProduct;
		while (pointer != null)
		{
			temporary = pointer;
			pointer = pointer.next;
			temporary.next=null;
			product = add (product,temporary);
		}//end while
		
		
		//deleting 0 coefficient polynomials
		pointer = product.next;
		Node prev = product;
		while (pointer != null)
		{
			if (pointer.term.coeff ==0)
				{
				prev.next = pointer.next;
				}//end if
				else 
					prev = prev.next;
					pointer=pointer.next;
		}//end while
						
		/** COMPLETE THIS METHOD **/
		// FOLLOWING LINE IS A PLACEHOLDER TO MAKE THIS METHOD COMPILE
		// CHANGE IT AS NEEDED FOR YOUR IMPLEMENTATION
		return product.next;
	}
		
	/**
	 * Evaluates a polynomial at a given value.
	 * 
	 * @param poly Polynomial (front of linked list) to be evaluated
	 * @param x Value at which evaluation is to be done
	 * @return Value of polynomial p at x
	 */
	public static float evaluate(Node poly, float x) {
		/** COMPLETE THIS METHOD **/
		
		float totals = 0;
		while (poly != null) {
			totals += poly.term.coeff * (Math.pow(x, poly.term.degree));
			poly = poly.next;
		} //end while
		
		// FOLLOWING LINE IS A PLACEHOLDER TO MAKE THIS METHOD COMPILE
		// CHANGE IT AS NEEDED FOR YOUR IMPLEMENTATION
		return totals;
	}
	
	/**
	 * Returns string representation of a polynomial
	 * 
	 * @param poly Polynomial (front of linked list)
	 * @return String representation, in descending order of degrees
	 */
	public static String toString(Node poly) {
		if (poly == null) {
			return "0";
		} 
		
		String retval = poly.term.toString();
		for (Node current = poly.next ; current != null ;
		current = current.next) {
			retval = current.term.toString() + " + " + retval;
		}
		return retval;
	}	
}

