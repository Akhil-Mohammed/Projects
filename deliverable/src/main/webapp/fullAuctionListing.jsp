<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Auction Listing</title>
</head>
<body>
<%
try{
	// should not happen
	if(session == null){
		response.sendRedirect("index.jsp");
	}
	if(session.getAttribute("userId") == null){
		response.sendRedirect("index.jsp");
	}
	Integer userId = (Integer)session.getAttribute("userId");
	String source = request.getParameter("source");
	if (source != null && source.equals("placeBid")){
		String expiredAuction = request.getParameter("expiredAuction");
		out.print("<span>Auction: " + expiredAuction + " has expired</span>");
		out.print("<br>");
	}
	// Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection conn = db.getConnection();

	if (conn == null) {
		System.out.println("Could not connect to database");
		out.print("Could not connect to database");
		response.sendRedirect("index.jsp?error=failed");
	}
	%>
	<b>Full Auction Listing:</b>
	<br> <br>
	<%
	
	// query Auction and Item table to get list of all auctions user can bid on 
	String stmt = "SELECT a.auctionId auctionId, a.auctionName auctionName," +
		" a.endingDateTime endingDateTime, i.name itemName, i.itemStatus itemStatus FROM " +
		"Auction a, Item i WHERE a.itemId = i.itemId AND i.userId <> ? AND i.itemStatus = ? "
		+ "ORDER BY a.endingDateTime ASC";
	PreparedStatement ps = conn.prepareStatement(stmt);
	ps.setInt(1, userId);
	ps.setInt(2, 0);
	ResultSet rs = ps.executeQuery();
	
	// create lists for each field
	
	ArrayList<Integer> auctionIds = new ArrayList<Integer>();
	ArrayList<String> auctionNames = new ArrayList<String>();
	ArrayList<String> auctionEndings = new ArrayList<String>();
	ArrayList<String> itemNames = new ArrayList<String>();
	
	while(rs.next()){
		auctionIds.add(rs.getInt("auctionId"));
		auctionNames.add(rs.getString("auctionName"));
		auctionEndings.add(rs.getString("endingDateTime"));
		itemNames.add(rs.getString("itemName"));
	}
	
	for (int i = auctionIds.size() - 1; i >= 0; i--){
		int auctionId = auctionIds.get(i);
		if(!DateCheck.isLiveAuction(auctionEndings.get(i))){
			Auction.endAuction(auctionId, conn);
			auctionIds.remove(i);
			auctionNames.remove(i);
			auctionEndings.remove(i);
			itemNames.remove(i);
			continue;
		}
	}
	
	
	if (auctionIds.size() == 0){
		out.print("There are no auctions to bid on");
	}
	else{
		// list all auctions
		
		%>
		<form method = "post">
		<table>
			<tr>
				<td><b>Auction ID</b></td>
				<td><b>Auction Name</b></td>
				<td><b>Item Name</b></td>
				<td><b>Ending Date/Time</b></td>
			</tr>
			<%
				for(int i = 0; i < auctionIds.size(); i++){
					int auctionId = auctionIds.get(i);
					String auctionName = auctionNames.get(i);
					String auctionEnding = auctionEndings.get(i);
					auctionEnding = auctionEnding.substring(0, auctionEnding.length() - 2);
					String itemName = itemNames.get(i);
					%>
					<tr>
						<td>
							<input type = "radio" id = "<%= auctionId%>" name = "auctionId" 
							value = "<%= auctionId%>" <% if(i == 0) out.print("checked"); %>>
							<label for = "<%=auctionId %>"><%=auctionId %></label>
						</td>
						<td>
							<% out.print(auctionName); %>
						</td>
						<td>
							<% out.print(itemName); %>
						</td>
						<td>
							<% out.print(auctionEnding); %>
						</td>
					</tr>
					<%
				}
			%>
			</table>
			<input type = "submit" value = "Place Bid" formaction = "placeBid.jsp">
			<input type = "submit" value = "View Information" formaction = "auctionInformation.jsp">
	 	</form>
	 	<% 
	} %>
	
	<br>
	<a href="account.jsp">Back</a>
	<%
	
} catch (Exception e){
	
}




%>
</body>
</html>