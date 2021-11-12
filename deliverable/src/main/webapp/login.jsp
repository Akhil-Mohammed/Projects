<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Auction Site | Logging in... </title>
</head>
<body>
	<%	
		try {
			String email = request.getParameter("email");
			String password = request.getParameter("password");
			String userType = request.getParameter("userType");
			
			if (email == null || password == null || userType == null) {
				// redirect to index
				response.sendRedirect("index.jsp?error=missing");
			}
			
			// TODO: validate email is actually an email
			if (email.isEmpty()) {
				response.sendRedirect("index.jsp?error=invalid");
			}

			if (password.isEmpty()) {
				response.sendRedirect("index.jsp?error=invalid");
			}

			String userTable = "";
			if (userType.equals("endUser")) {
				userTable = "endUser";
			}
			else if (userType.equals("cs")) {
				userTable = "customerSupport";
			}
			else if (userType.equals("admin")) {
				userTable = "administrator";
			}
			
			// should not happen
			if (userTable.isEmpty()) {
				response.sendRedirect("index.jsp?error=invalid");
			}
			
			// Get the database connection
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();

			if (con == null) {
				System.out.println("Could not connect to database");
				out.print("Could not connect to database");
				response.sendRedirect("index.jsp?error=failed");
			}
			
			// prepare login query
			String str = "SELECT userId FROM "+userTable+" WHERE email=? AND pw=?";
			PreparedStatement stmt = con.prepareStatement(str);
			stmt.setString(1, email);
			stmt.setString(2, password);
			
			// execute login query
			ResultSet result = stmt.executeQuery();
			
			// login failed (user does not exist, wrong email/password, wrong table, etc.)
			if (!result.next()) {
				db.closeConnection(con);
				response.sendRedirect("index.jsp?error=failed");
			}
			
			Integer userId = result.getInt("userId");

			db.closeConnection(con);
			
			// set session attributes
			session.setAttribute("userId", userId);
			session.setAttribute("userTable", userTable);
			
			response.sendRedirect("account.jsp");
		} catch (Exception e) {
			out.print(e);
		}
	%>

</body>
</html>