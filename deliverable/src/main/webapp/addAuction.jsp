<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat, java.text.DecimalFormat" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Add Auction</title>
</head>
<body>
<%
try{
	
	final int MAX_AUCTION_NAME_LEN = 100;
	final int MAX_DESCRIPTION_LEN = 1000;
	
	// should not happen
	if(session == null){
		response.sendRedirect("index.jsp");
	}
	if(session.getAttribute("userId") == null){
		response.sendRedirect("index.jsp");
	}
	
	// only endUsers can make auctions to be added to the Auction table
	String userTable = (String) session.getAttribute("userTable");
	if (userTable == null || !userTable.equals("endUser")){
		response.sendRedirect("account.jsp");
	}
	
	// should not be null
	String itemID = request.getParameter("itemId");
	if(itemID == null || itemID.isEmpty()){
		response.sendRedirect("userItems.jsp");
	}
	Integer itemId = Integer.parseInt(itemID);
	
	// error check for empty auction name
	String auctionName = request.getParameter("auctionName");
	if(auctionName == null || auctionName.trim().isEmpty() || auctionName.length() > MAX_AUCTION_NAME_LEN){
		%>
		<form id = "invalidName" method = "post" action = "createAuction.jsp?error=invalidName">
			<input type = "hidden" name = "items" value = "<%=itemId %>">
			<script>document.getElementById("invalidName").submit();</script>
		</form>
		<%
	}
	// description is optional
	String description = request.getParameter("description");
	if(description == null){
		description = "";
	}
	// error check for description length
	if(description.length() > MAX_DESCRIPTION_LEN){
		%>
		<form id = "invalidDescription" method = "post" action = "createAuction.jsp?error=invalidDescription">
			<input type = "hidden" name = "items" value = "<%=itemId %>">
			<script>document.getElementById("invalidDescription").submit();</script>
		</form>
		<%
	}
	
	
	// check if prices are valid
	String minPrice = request.getParameter("minReserve");
	String startPrice = request.getParameter("startPrice");
	String incPrice = request.getParameter("incPrice");
	String endTime = request.getParameter("endTime");
	
	if (!Prices.isValidPrice(minPrice) || !Prices.isValidPrice(startPrice) || !Prices.isValidPrice(incPrice) || Prices.getPrice(incPrice) <= 0){
		%>
		<form id = "invalidPrice" method = "post" action = "createAuction.jsp?error=invalidPrice">
			<input type = "hidden" name = "items" value = "<%=itemId %>">
 			<script>document.getElementById("invalidPrice").submit();</script>
		</form>
		<%
	}
	else if(endTime == null || !DateCheck.validCreate(endTime)){
		%>
		<form id = "invalidDate" method = "post" action = "createAuction.jsp?error=invalidDate">
			<input type = "hidden" name = "items" value = "<%=itemId %>">
			<script>document.getElementById("invalidDate").submit();</script>
		</form>
		<%
	}
	else {
		// make information provided compatible data types with SQL insert
		
		double minimumPrice = Prices.getPrice(minPrice);
		double startingPrice = Prices.getPrice(startPrice);
		double incrementPrice = Prices.getPrice(incPrice);
		
		String endingDate = endTime.replace('T', ' ');
		endingDate += ":00"; 
		
		//Get the database connection
		ApplicationDB db = new ApplicationDB();	
		Connection conn = db.getConnection();
			
		if (conn == null) {
			System.out.println("Could not connect to database");
			out.print("Could not connect to database");
			response.sendRedirect("index.jsp?error=failed");
		}
		else {
			// find string for current datetime
			SimpleDateFormat format = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss");
			String startingDate = format.format(new java.util.Date());
			
					
			// insert into auction table
			String stmt = "INSERT into Auction (auctionName, description, minPrice," + 
					"startPrice, incPrice, startingDateTime, endingDateTime, itemId) VALUES (?,?,?,?,?,?,?,?)";
			PreparedStatement ps = conn.prepareStatement(stmt);
			ps.setString(1, auctionName);
			ps.setString(2, description);
			ps.setDouble(3, minimumPrice);
			ps.setDouble(4, startingPrice);
			ps.setDouble(5, incrementPrice);
			ps.setString(6, startingDate);
			ps.setString(7, endingDate);
			ps.setInt(8, itemId);
			ps.executeUpdate();

			db.closeConnection(conn);
			response.sendRedirect("account.jsp");	
		}
	}
} catch(Exception e){
	out.print(e);
}

%>

</body>
</html>