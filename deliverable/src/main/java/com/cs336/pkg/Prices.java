package com.cs336.pkg;

import java.text.DecimalFormat;

public class Prices {
	public static final double MAX_AMOUNT = 999999999999999.99;

	public static double getPrice (String price) {
		double amount = Double.parseDouble(price);
		DecimalFormat df = new DecimalFormat("#.##");
	    amount = Double.parseDouble(df.format(amount));
	    return amount;
	}
	
	public static String formatPrice (double price) {
		double cutoff = 100.0;
		price = Math.round(price * cutoff) / cutoff;
        return "$" + String.format("%.2f", price); // cuts the string to display number with two decimal places
	}

	public static boolean isValidPrice (String price){
		if(price == null){
			return false;
		}
		price = price.trim();
		if (price.isEmpty()) {
			return false;
		}
		
		try {
			double amount = getPrice(price);
			return amount >= 0 && amount <= MAX_AMOUNT;
		} catch (NumberFormatException e) {
			return false;	
		}
	}
	
	public static boolean isValidBid(double bidAmount, double startPrice, double highestBidAmount, double incPrice){
		if(highestBidAmount == 0) { // no bids placed yet
			if(startPrice == 0){
				return bidAmount > startPrice; // don't allow initial bid to be 0
			}
			return bidAmount >= startPrice; // otherwise initial bid can be startPrice or greater
		}
		return bidAmount >= highestBidAmount + incPrice;
	}
}
