package com.cs336.pkg;

import java.sql.*;

public class ValueValidation {
	public static final int MAX_NAME_LEN = 50;
	public static final int MIN_PASS_LEN = 8;
	public static final int MAX_PASS_LEN = 100;
	public static final int MAX_EMAIL_LEN = 100;
	
	public static boolean tableHasEmail(Connection con, String userTable, String email) throws SQLException {
		return tableHasEmail(con, userTable, email, -1);
	}
	
	public static boolean tableHasEmail(Connection con, String userTable, String email, int userId) throws SQLException {
		String sql = userId > 0 ? 
				"SELECT userId FROM "+userTable+" WHERE email=? AND userId != ?" :
				"SELECT userId FROM "+userTable+" WHERE email=?";

		PreparedStatement stmt = con.prepareStatement(sql);
		stmt.setString(1, email);
		if (userId > 0) {
			stmt.setInt(2, userId);
		}
		ResultSet result = stmt.executeQuery();
		return result.next();
	}
	
	public static boolean isValidPassword(String password) {
		int passLen = password.length();
		return passLen >= MIN_PASS_LEN && passLen <= MAX_PASS_LEN;
	}
	
	public static boolean isValidName(String name) {
		if (!name.equals(name.trim())) return false;
		if (name.isEmpty()) return false;
		if (name.length() > MAX_NAME_LEN) return false;
		return true;
	}
}
