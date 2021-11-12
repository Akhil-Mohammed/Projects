package com.cs336.pkg;
import java.io.*;
import java.util.*;
import java.sql.*;
import java.util.Date;
import java.time.LocalDate;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.servlet.http.*;
import javax.servlet.*;



public class Auction {
	private int id;
	private String name;
	private String endingDate;

	private Auction(int id, String name, String endingDate) {
		this.id = id;
		this.name = name;
		this.endingDate = endingDate;
	}
	
	public String getName() {
		return this.name;
	}
	
	public int getId() {
		return this.id;
	}
	
	public String getEndingDate() {
		return this.endingDate;
	}
	
	// returns false if failed, true if successful
	public static boolean endAuction(int auctionId, Connection conn) throws SQLException{
		try{
			if (conn == null) {
				return false;
			}
			
			// get auction info
			String auctionInfo = "SELECT auctionName, minPrice, itemId FROM Auction WHERE auctionId = ?";
			PreparedStatement auctionInfoStmt = conn.prepareStatement(auctionInfo);
			auctionInfoStmt.setInt(1, auctionId);
			ResultSet auctionInfoResult = auctionInfoStmt.executeQuery();
			// default value
			String auctionName = "";
			String minPrice = "";
			int itemId = 0; 
			while(auctionInfoResult.next()){
				auctionName = auctionInfoResult.getString("auctionName");
				minPrice = auctionInfoResult.getString("minPrice");
				itemId = auctionInfoResult.getInt("itemId");
			}
			
			// get item info
			String itemInfo = "SELECT i.name name, e.userId userId FROM Item i, endUser e WHERE itemId = ? AND i.userId = e.userId";
			PreparedStatement itemInfoStmt = conn.prepareStatement(itemInfo);
			itemInfoStmt.setInt(1, itemId);
			ResultSet itemInfoRS = itemInfoStmt.executeQuery();
			itemInfoRS.next();
			String itemName = itemInfoRS.getString("name");
			int sellerId = itemInfoRS.getInt("userId");
			
			
			// once an auction is over the item can not be resold on the site even if there was no winner
			String isSoldCmd = "UPDATE Item SET itemStatus = ? WHERE itemId = ?";
			PreparedStatement isSoldStmt = conn.prepareStatement(isSoldCmd);
			isSoldStmt.setInt(2, itemId);
			
			double minReserve = Prices.getPrice(minPrice);
			// get highest bid amount from auction/bid tables
			// query to get highest auction bid (may change after insert)
			String getHighestBid = "SELECT amount, userId FROM Bid WHERE auctionId = ? AND amount IN (SELECT max(amount) FROM Bid WHERE auctionId = ? GROUP BY auctionId)";
			PreparedStatement auctionGHB = conn.prepareStatement(getHighestBid);
			auctionGHB.setInt(1, auctionId);
			auctionGHB.setInt(2, auctionId);
			ResultSet auctionRHB = auctionGHB.executeQuery();
			String highestBid = "";
			String alert = "";
			int winnerId = 0;
			double highestBidAmount = 0;
			if (!auctionRHB.next()){ // no bids were placed
				alert = "No users won the auction: " + auctionName + " for item: " + itemName;
				isSoldStmt.setInt(1, 2);
			}else{
				highestBid = auctionRHB.getString("amount");
				highestBidAmount = Prices.getPrice(highestBid);
				if (highestBidAmount < minReserve){ // no winners
					alert = "No users won the auction: " + auctionName + " for item: " + itemName;
					isSoldStmt.setInt(1,2);
				}
				else{
					winnerId = auctionRHB.getInt("userId");
					String getWinnerInfo = "SELECT fname, lname FROM endUser e WHERE userId = ?";
					PreparedStatement winnerStmt = conn.prepareStatement(getWinnerInfo);
					winnerStmt.setInt(1, winnerId);
					ResultSet winnerRS = winnerStmt.executeQuery();
					winnerRS.next();
					String fname = winnerRS.getString("fname");
					String lname = winnerRS.getString("lname");
					alert = fname + " " + lname + " won the auction: " + auctionName + " for item: " + itemName + " with a bid of: " + Prices.formatPrice(highestBidAmount);
					isSoldStmt.setInt(1,1);
				}
			}
			// depending on if there was a winner or not execute update
			int soldStatus = isSoldStmt.executeUpdate();
			
			// send alert about auction ending to all buyers
			// get all other buyers involved in auction
			String getBuyers = "SELECT distinct userId FROM Bid WHERE auctionId = ?";
			PreparedStatement auctionGB = conn.prepareStatement(getBuyers);
			auctionGB.setInt(1, auctionId);
			ResultSet auctionRB = auctionGB.executeQuery();
			ArrayList<String> buyerIds = new ArrayList<String>();
			while (auctionRB.next()){
				buyerIds.add(auctionRB.getString("userId"));
			}
			// find string for current datetime
			SimpleDateFormat format = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss");
			String currDateTime = format.format(new java.util.Date());
			for(int i = 0; i < buyerIds.size(); i++){
				String buyerID = buyerIds.get(i);
				Integer buyerId = Integer.parseInt(buyerID);
				String insertAlert = "INSERT into Alert (userId, alertMessage, alertDateTime) VALUES (?, ?, ?)";
				PreparedStatement auctionIA = conn.prepareStatement(insertAlert);
				auctionIA.setInt(1, buyerId);
				if(buyerId == winnerId){
					auctionIA.setString(2, "You won the auction: " + auctionName + " for item: " + itemName + " with a bid of: " + Prices.formatPrice(highestBidAmount));
				}
				else{
					auctionIA.setString(2, alert);
				}
				auctionIA.setString(3, currDateTime);
				int messageStatus = auctionIA.executeUpdate();
			}
			
			// send alert an seller that auction has concluded
			String sellerAlert = "INSERT into Alert (userId, alertMessage, alertDateTime) VALUES(?, ?, ?)";
			PreparedStatement sellerIA = conn.prepareStatement(sellerAlert);
			sellerIA.setInt(1, sellerId);
			sellerIA.setString(2, "Your auction: " + auctionName + " for item: " + itemName + " has concluded");
			sellerIA.setString(3, currDateTime);
			int sellerAlertStatus = sellerIA.executeUpdate();
			
			return true; 
			
			
		} catch(Exception e){
			return false;
		}

	}
	
	public boolean delete() {		
		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();
		
		if (con == null) {
			return false;
		}

		boolean success = true;

		
		try {
			if (!DateCheck.isLiveAuction(endingDate)) {
				Auction.endAuction(id, con);
				success = false;
			}
		} catch (ParseException e) {
			success = false;
		} catch (SQLException e) {
			success = false;
		}
		
		if (!success) {
			db.closeConnection(con);
			return false;
		}
		
		try {			
			String sql = "DELETE FROM Auction WHERE auctionId = ? AND (SELECT i.itemStatus FROM Item i WHERE itemId = i.itemId LIMIT 1) = 0";
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setInt(1, id);
			success = stmt.executeUpdate() == 1;
		} catch(SQLException e) {
			e.printStackTrace();
			success = false;
		}
		
		db.closeConnection(con);
		return success;
	}
	
	public static ArrayList<Auction> getAuctions() {
		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();
		
		if (con == null) {
			return null;
		}
		
		try {
			String sql = "SELECT auctionId, auctionName, endingDateTime FROM Auction JOIN Item using(itemId) WHERE itemStatus = 0";
			ResultSet results = con.createStatement().executeQuery(sql);
			
			ArrayList<Auction> auctions = new ArrayList<Auction>();
			while (results.next()) {
				int id = results.getInt("auctionId");
				String name = results.getString("auctionName");
				String ending = results.getString("endingDateTime");
				
				try {
					if (DateCheck.isLiveAuction(ending)) {
						auctions.add(new Auction(
							id,
							name,
							ending
						));
					}
					else {
						Auction.endAuction(id, con);
					}
				} catch (ParseException e) {
					e.printStackTrace();
				}
			}
			
			db.closeConnection(con);
			
			return auctions;
		} catch(SQLException e) {
			e.printStackTrace();
			db.closeConnection(con);
			return null;
		}
	}
}
