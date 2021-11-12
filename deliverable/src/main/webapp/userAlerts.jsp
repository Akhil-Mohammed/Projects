<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Alerts</title>
</head>
<body>
Alerts:
<br>
<%

try{
	// should not happen
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
	
	Integer userId = (Integer) session.getAttribute("userId");
	String viewType = request.getParameter("alertGroup");
	if (viewType == null || (!viewType.equals("viewUnread") && !viewType.equals("viewAll"))){ // should not be possible, being safe with this check
		response.sendRedirect("account.jsp");
		return;
	}
	
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection conn = db.getConnection();
			
	if (conn == null) {
		System.out.println("Could not connect to database");
		out.print("Could not connect to database");
		response.sendRedirect("index.jsp?error=failed");
	}
	
	String stmt = "";
	PreparedStatement ps = conn.prepareStatement("");
	if(viewType.equals("viewUnread")){
		stmt = "SELECT alertId, alertMessage, alertDateTime FROM Alert WHERE userId = ? AND alertRead = ? ORDER BY alertDateTime DESC";
		ps = conn.prepareStatement(stmt);
		ps.setInt(1, userId);
		ps.setInt(2, 0);
	}
	else{
		stmt = "SELECT alertId, alertMessage, alertDateTime FROM Alert WHERE userId = ? ORDER BY alertDateTime DESC";
		ps = conn.prepareStatement(stmt);
		ps.setInt(1, userId);
	}
	ResultSet rs = ps.executeQuery();
	ArrayList<String> alerts = new ArrayList<String>();
	ArrayList<String> dates = new ArrayList<String>();
	ArrayList<String> ids = new ArrayList<String>();
	while (rs.next()){
		alerts.add(rs.getString("alertMessage"));
		dates.add(rs.getString("alertDateTime"));
		ids.add(rs.getString("alertId"));
	}
	if(ids.size() == 0){
		out.print("No new alerts to be displayed");
		out.print("<br>");
	}
	else{
		%>
		
		<table>
		<tr>
			<td>Message</td>
			<td>Date and Time</td>
		</tr>
			<%
			for (int i = 0; i < alerts.size(); i++){
				out.print("<tr>");
				out.print("<td>");
				out.print(alerts.get(i));
				out.print("</td>");
				out.print("<td>");
				out.print(dates.get(i).substring(0, dates.get(i).length() - 2));
				out.print("</td>");
				out.print("</tr>");
			}
			%>
		</table>
		<%
		for(int i = 0; i < ids.size(); i++){
			String update = "UPDATE Alert SET alertRead = ? WHERE alertId = ?";
			PreparedStatement updateStmt = conn.prepareStatement(update);
			updateStmt.setInt(1, 1);
			updateStmt.setString(2, ids.get(i));
			int status = updateStmt.executeUpdate();
		}
		
		db.closeConnection(conn);
		
	} %>
	
	<br> <br>
	<form method = "post" action = "account.jsp">
		<input type = "submit" value = "Back">
	</form>

	<%
	
} catch (Exception e){
	out.print(e);
}


%>
</body>
</html>