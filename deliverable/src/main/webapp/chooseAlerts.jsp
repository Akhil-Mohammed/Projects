<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Select Alerts to View</title>
</head>
<body>

<%
//should not happen
if(session == null){
	response.sendRedirect("index.jsp");
	return;
}
if(session.getAttribute("userId") == null){
	response.sendRedirect("index.jsp");
	return;
}
	
String userTable = (String) session.getAttribute("userTable");
if (userTable == null || !userTable.equals("endUser")){
	response.sendRedirect("account.jsp");
	return;
}

%>


Choose Alerts to View:
<br>
<form method = "post" action = "userAlerts.jsp">
	<input type = "radio" id = "viewUnread" name = "alertGroup" value = "viewUnread" checked>
	<label for = "viewUnread">View Unread Alerts</label>
	<br>
	<input type = "radio" id = "viewAll" name = "alertGroup" value = "viewAll">
	<label for = "viewAll">View All Alerts</label>
	<br>
	<input type = "submit" value = "Confirm">
</form>
<br>
<a href = "account.jsp">Back</a>
</body>
</html>