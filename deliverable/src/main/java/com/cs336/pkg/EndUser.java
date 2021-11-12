package com.cs336.pkg;

import java.sql.*;
import java.util.*;

public class EndUser {
	private int id;
	private String firstName, lastName, email, password;

	private EndUser(int id, String firstName, String lastName, String email, String password) {
		this.id = id;
		this.firstName = firstName;
		this.lastName = lastName;
		this.email = email;
		this.password = password;
	}

	private boolean setString(String field, String value) {
		ApplicationDB db = new ApplicationDB();
		Connection con = db.getConnection();

		if (con == null) return false;
		
		String sql = String.format("UPDATE EndUser SET %s = ? WHERE userId = ?", field);
		boolean success = false;
		try {
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setString(1, value);
			stmt.setInt(2, this.id);
			int hasUpdate = stmt.executeUpdate();
			success = hasUpdate == 1;
		} catch (SQLException e) {
			success = false;
		}
		finally {
			db.closeConnection(con);
		}
		
		return success;
	}
	
	public void setFirstName(String firstName) {
		if (setString("fName", firstName)) {
			this.firstName = firstName;
		}
	}

	public void setLastName(String lastName) {
		if (setString("lName", lastName)) {
			this.lastName = lastName;
		}
	}

	public void setEmail(String email) {
		if (setString("email", email)) {
			this.email = email;
		}
	}

	public void setPassword(String password) {
		if (setString("pw", password)) {
			this.password= password;
		}
	}
	
	public int getId() {
		return id;
	}

	public String getFirstName() {
		return firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public String getEmail() {
		return email;
	}

	public String getPassword() {
		return password;
	}
	
	public static boolean deleteUser(int userId) {
		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();
		
		if (con == null) {
			return false;
		}
		
		boolean success = false;
		try {
			String sql2 = "DELETE FROM Item WHERE userId = ? AND itemStatus = 0";
			PreparedStatement stmt2 = con.prepareStatement(sql2);
			stmt2.setInt(1, userId);
			stmt2.executeUpdate();
			
			String sql3 = "DELETE FROM Bid b where b.userId = ? AND (SELECT itemStatus FROM Item i WHERE i.itemId = (SELECT itemId FROM Auction a WHERE b.auctionId = a.auctionId LIMIT 1)) = 0";
			PreparedStatement stmt3 = con.prepareStatement(sql3);
			stmt3.setInt(1, userId);
			stmt3.executeUpdate();
			
			String sql = "DELETE FROM EndUser where userId = ?";
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setInt(1, userId);
			success = stmt.executeUpdate() == 1;
		} catch(SQLException e) {
			e.printStackTrace();
			success = false;
		}
		
		db.closeConnection(con);
		return success;
	}
	
	public static ArrayList<EndUser> getEndUsers() {
		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();
		
		if (con == null) {
			return null;
		}
		
		try {
			String sql = "SELECT * FROM EndUser";
			ResultSet results = con.createStatement().executeQuery(sql);
			
			ArrayList<EndUser> users = new ArrayList<EndUser>();
			while (results.next()) {
				int id = results.getInt("userId");
				String email = results.getString("email");
				String password = results.getString("pw");
				String firstName = results.getString("fName");
				String lastName = results.getString("lName");
				
				users.add(new EndUser(
					id,
					firstName,
					lastName,
					email,
					password
				));
			}
			
			db.closeConnection(con);
			
			return users;
		} catch(SQLException e) {
			e.printStackTrace();
			db.closeConnection(con);
			return null;
		}
	}
}
