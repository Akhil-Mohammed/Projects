<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>



<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Auction Site | Login</title>
	</head>
	
	<body>	
		<% 
			// if already logged in, go to account page		
			if (session.getAttribute("userId") != null && session.getAttribute("userTable") != null){
				response.sendRedirect("account.jsp");
			}

			String error = request.getParameter("error");
			if (error != null) {
				if (error.equals("missing"))
				{
					out.print("<span>Missing parameters</span>");	
				}
				else if (error.equals("invalid"))
				{
					out.print("<span>Invalid parameters</span>");	
				}
				else if (error.equals("failed"))
				{
					out.print("<span>Login failed</span>");	
				}
				out.print("<br>");
			}
		%>
	
		<form method="post" action="login.jsp">
			<label for="email">E-Mail</label>
			<input required id="email" type="email" name="email"/>
			<br>
			<label for="password">Password</label>
			<input required id="password" type="password" name="password"/>
			<br>
			<span>User Type:</span>
			<br>
			<label for="endUser">User</label>
			<input type="radio" id="endUser" name="userType" value="endUser" checked>
			<br>
			<label for="admin">Administrator</label>
			<input type="radio" id="admin" name="userType" value="admin">
			<br>
			<label for="cs">Customer Support</label>
			<input type="radio" id="cs" name="userType" value="cs">
			<br>
			<input type="submit" value="Login" />
		</form>

		<br>
		<a href="register.jsp">Don't have an account? Register here</a>

</body>
</html>