<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Auction Site | Register</title>
	</head>
	
	<body>
		<%		
			try {
				String email = request.getParameter("email");
				String password = request.getParameter("password");
				String firstName = request.getParameter("firstName");
				String lastName = request.getParameter("lastName");
				
				if (email != null && password != null && firstName != null && lastName != null) {
					email = email.trim();
					
					if (email.isEmpty()) {
						response.sendRedirect("register.jsp?error=invalid");
						return;
					}

					// validate password
					if (!ValueValidation.isValidPassword(password)) {
						response.sendRedirect("register.jsp?error=passLen");
						return;
					}
		
					// TODO: validate email is actually an email

					// validate names
					if (!ValueValidation.isValidName(firstName) || !ValueValidation.isValidName(lastName)) {
						response.sendRedirect("register.jsp?error=name");
						return;
					}
					
					// Get the database connection
					ApplicationDB db = new ApplicationDB();	
					Connection con = db.getConnection();
		
					if (con == null) {
						out.print("Could not connect to database");
						return;
					}
					
					// check to make sure email is not taken
					String[] tables = new String[] { "endUser", "administrator", "customerSupport" };
					for (String table : tables) {
						if (ValueValidation.tableHasEmail(con, table, email)) {
							db.closeConnection(con);
							response.sendRedirect("register.jsp?error=taken");
							return;
						}
					}

					// email is valid and not taken, so create account
					String str = "INSERT INTO endUser (fName, lName, email, pw) VALUES (?, ?, ?, ?)";
					PreparedStatement stmt = con.prepareStatement(str);
					stmt.setString(1, firstName);
					stmt.setString(2, lastName);
					stmt.setString(3, email);
					stmt.setString(4, password);
					
					int addUserResult = stmt.executeUpdate();
					
					db.closeConnection(con);
		%>
					<form id="loginForm" method="post" action="login.jsp">
					<input hidden id="email" type="email" name="email" value="<%=email%>"/>
					<input hidden id="password" type="password" name="password" value="<%=password%>"/>
					<input hidden type="radio" id="endUser" name="userType" value="endUser" checked>
					</form>
					<script>document.getElementById("loginForm").submit();</script>
		<% 
				}
			} catch (Exception e) {
				out.print(e);
			}
		%>

		<% 
			String error = request.getParameter("error");
			if (error != null) {
				if (error.equals("invalid"))
				{
					out.print("<span>Invalid parameters</span>");	
				}
				else if (error.equals("passLen"))
				{
					out.print("<span>Password must be at least "+ValueValidation.MIN_PASS_LEN+" and at most "+ValueValidation.MAX_PASS_LEN+" characters</span>");
				}
				else if (error.equals("taken"))
				{
					out.print("<span>Email is taken</span>");
				}
				else if (error.equals("name"))
				{
					out.print("<span>Invalid name</span>");
				}
				else if (error.equals("failed"))
				{
					out.print("<span>Registration failed</span>");	
				}
				out.print("<br>");
			}
		%>
	
		<form method="post" action="register.jsp">
			<label for="email">E-Mail</label>
			<input required id="email" type="email" name="email"/>
			<br>
			<label for="password">Password</label>
			<input required id="password" type="password" name="password"/>
			<br>
			<label for="firstName">First Name</label>
			<input required id="firstName" type="text" name="firstName"/>
			<br>
			<label for="lastName">Last Name</label>
			<input required id="lastName" type="text" name="lastName"/>
			<br>
			<input type="submit" value="Register" />
		</form>
		
		<br>
		<a href="index.jsp">Already have an account? Login here</a>
</body>
</html>