package com.cs336.pkg;

import java.util.*;
import java.sql.*;
import java.util.Date;
import java.math.BigDecimal;

public class Bid {
	private BigDecimal amount;
	private int userId, auctionId;
	private Date bidDateTime;
	
	private Bid(int auctionId, int userId, BigDecimal amount, Date bidDateTime) {
		this.auctionId = auctionId;
		this.userId = userId;
		this.amount = amount;
		this.bidDateTime = bidDateTime;
	}
	
	public int getAuctionId() {
		return this.auctionId;
	}
	
	public int getUserId() {
		return this.userId;
	}
	
	public BigDecimal getAmount() {
		return this.amount;
	}
	
	public Date getBidDateTime() {
		return this.bidDateTime;
	}
	
	public static ArrayList<Bid> getBids(int auctionId) {
		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();
		
		if (con == null) {
			return null;
		}
		
		try {
			String sql = "SELECT * FROM Bid WHERE auctionId = ? ORDER BY bidDateTime";
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setInt(1, auctionId);
			ResultSet results = stmt.executeQuery();
			
			ArrayList<Bid> bids = new ArrayList<Bid>();
			while (results.next()) {
				int userId = results.getInt("userId");
				BigDecimal amount = results.getBigDecimal("amount");
				Date bidDateTime = results.getTimestamp("bidDateTime");
				
				bids.add(new Bid(
					auctionId,
					userId,
					amount,
					bidDateTime
				));
			}
			
			db.closeConnection(con);
			
			return bids;
		} catch(SQLException e) {
			e.printStackTrace();
			db.closeConnection(con);
			return null;
		}
	}
	
	public static boolean deleteBid(int auctionId, BigDecimal amount) {
		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();
		
		if (con == null) {
			return false;
		}
		
		try {
			String sql = "DELETE FROM Bid WHERE auctionId = ? AND amount = ? ";
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setInt(1, auctionId);
			stmt.setBigDecimal(2, amount);
			int result = stmt.executeUpdate();
			boolean success = result == 1;
			
			db.closeConnection(con);
			
			return success;
		} catch(SQLException e) {
			e.printStackTrace();
			db.closeConnection(con);
			return false;
		}
	}
}
