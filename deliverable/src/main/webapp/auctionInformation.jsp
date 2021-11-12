<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site| Auction Information</title>
</head>
<body>
<%!
public String createRow(Integer itemId, Connection conn) throws SQLException { 
	String result = "";
	// query Item to get the name of the item
	
	String stmt1 = "SELECT distinct name FROM Item WHERE itemId = ?";
	PreparedStatement ps1 = conn.prepareStatement(stmt1);
	ps1.setInt(1, itemId);
	ResultSet rs1 = ps1.executeQuery();
	String name = "";
	while(rs1.next()){
		name = rs1.getString("name");
	}
	result += itemId + "  " + "Name = " + name + ";  ";
	
	// query Item to get a table with Attribute Name and Values as columns
	
	String stmt2 = "SELECT catName, name, attributeValue FROM ItemAttribute where itemId = ?";
	PreparedStatement ps2 = conn.prepareStatement(stmt2);
	ps2.setInt(1, itemId);
	ResultSet rs2 = ps2.executeQuery();
	boolean catAssigned = false;
	while (rs2.next()){
		if(!catAssigned){
			String catType = rs2.getString("catName");
			String attrName = rs2.getString("name");
			String attrVal = rs2.getString("attributeValue");
			result += "Subcategory = " + catType + "; Attributes: "   + attrName +  " =  " + attrVal + ", ";
			catAssigned = true;
		}
		else{
			String attrName = rs2.getString("name");
			String attrVal = rs2.getString("attributeValue");
			result += attrName +  " =  " + attrVal + ", ";
		}
		
	}
	
	return result.substring(0, result.length() - 2);
}


%>
<%
try{
	// should not happen
	if(session == null){
		response.sendRedirect("index.jsp");
	}
	if(session.getAttribute("userId") == null){
		response.sendRedirect("index.jsp");
	}
	
	String auctionID = request.getParameter("auctionId");
	if(auctionID == null || auctionID.isEmpty() ){
		response.sendRedirect("account.jsp");
	}
	Integer auctionId = Integer.parseInt(auctionID);
	
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection conn = db.getConnection();
	
	if (conn == null) {
		System.out.println("Could not connect to database");
		out.print("Could not connect to database");
		response.sendRedirect("index.jsp?error=failed");
	}
	
	// Get all of the auction information
	String auctionStmt = "SELECT auctionName, description, startPrice, incPrice, startingDateTime, endingDateTime FROM Auction WHERE auctionId = ?";
	PreparedStatement auctionPS = conn.prepareStatement(auctionStmt);
	auctionPS.setInt(1, auctionId);
	ResultSet auctionRS = auctionPS.executeQuery();
	
	String auctionName = "";
	String auctionDescription = "";
	String startPrice = "";
	String incPrice = "";
	String startingDateTime = "";
	String endingDateTime = "";
	
	while(auctionRS.next()){
		auctionName = auctionRS.getString("auctionName");
		auctionDescription = auctionRS.getString("description");
		startPrice = auctionRS.getString("startPrice");
		incPrice = auctionRS.getString("incPrice");
		startingDateTime = auctionRS.getString("startingDateTime");
		endingDateTime = auctionRS.getString("endingDateTime");
	}
	
	%>
	<b>Auction Information:</b>
	<br>
	<br>
	<table>
	<tr>
		<td><b>Auction Name:</b></td>
		<td><% out.print(auctionName); %></td>
	</tr>
	<tr>
		<td><b>Description:</b></td>
		<td><% out.print(auctionDescription); %></td>
	</tr>
	<tr>
		<td><b>Starting Price:</b></td>
		<td><% out.print(startPrice); %></td>
	</tr>
	<tr>
		<td><b>Increment Price:</b></td>
		<td><% out.print(incPrice); %></td>
	</tr>
	<tr>
		<td><b>Starting Date/Time:</b></td>
		<td><% out.print(startingDateTime.substring(0, startingDateTime.length() - 2)); %></td>
	</tr>
	<tr>
		<td><b>Ending Date/Time:</b></td>
		<td><% out.print(endingDateTime.substring(0, endingDateTime.length() - 2)); %></td>
	</tr>
	</table>
	<br> <br>
	<%
	// get item information
	String itemStmt = "SELECT i.itemId itemId FROM Item i, Auction a WHERE a.auctionId = ? AND a.itemId = i.itemId ";
	PreparedStatement itemPS = conn.prepareStatement(itemStmt);
	itemPS.setInt(1, auctionId);
	ResultSet itemRS = itemPS.executeQuery();
	itemRS.next();
	int itemId = itemRS.getInt("itemId");
	String row = createRow(itemId, conn);
	%>
	<b>Item Information:</b>
	<br>
	<%out.print(row.substring(2, row.length())); %>
	<br> <br>
	<a href="fullAuctionListing.jsp">Back</a>
	<% 
} catch (Exception e){
	out.print(e);
}


%>
</body>
</html>