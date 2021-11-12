<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | User Items</title>
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
	
	String userTable = (String) session.getAttribute("userTable");
	if (userTable == null || !userTable.equals("endUser")){
		response.sendRedirect("account.jsp");
	}
		
	Integer userId = (Integer)session.getAttribute("userId");
	
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection conn = db.getConnection();
				
	if (conn == null) {
		System.out.println("Could not connect to database");
		out.print("Could not connect to database");
		response.sendRedirect("index.jsp?error=failed");
	}
	
	// query Item to get all itemIds of items the user owns and are not on auction
	String stmt = "SELECT itemId FROM Item WHERE userId = ? AND itemStatus = ? AND itemId NOT IN (SELECT itemId from Auction) ORDER BY itemId asc";
	PreparedStatement ps = conn.prepareStatement(stmt);
	ps.setInt(1, userId);
	ps.setInt(2, 0);
	ResultSet rs = ps.executeQuery();
	
	// move ids into an ArrayList
	ArrayList<Integer> itemIdList = new ArrayList<Integer>();
	while(rs.next()){
		itemIdList.add(rs.getInt("itemId"));
	}
	if(itemIdList.size() == 0){
		%>
		<b>List of Items:</b>
		<br> <br>
		You have no items
		<%
	}
	else{
		// create an arraylist of strings where each string is a row in the displayed items list
		ArrayList<String> rows = new ArrayList<String>();
		for(int i = 0; i < itemIdList.size(); i++){
			String row = createRow(itemIdList.get(i), conn);
			rows.add(row);
		}
		// make rows a radio button group
		
		%>
		<b>List of Items:</b>
		<br> <br>
		ItemId		Item Information
		<form method = "post" action = "createAuction.jsp">
		<% 
		for(int i = 0; i < rows.size(); i++){ 
			String row = rows.get(i);
			String itemId = itemIdList.get(i).toString();
			%>
			<input type ="radio" id = "<%=itemId %>" name = "items" value = "<%=itemId %>"  
			<%if (i == 0) out.print("checked"); %>>
			<label for= "<%=itemId %>"> <%=row %> </label>
			<br>
			
			<% 
		} %>
		<br>
		<input type = "submit" value = "Create Auction For Selected Item">
		</form>
	<%} %>
	
	<br>
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	<br>
	<br>
	<b>List of Items on Auction:</b>
	<br> <br>
	<%
	String cmd = "SELECT i.itemId itemId, a.auctionId auctionId, a.endingDateTime endingDateTime FROM Item i, Auction a WHERE i.userId = ? AND i.itemStatus = ? AND i.itemId = a.itemId AND i.itemId IN (SELECT  "
				+ "a.itemId FROM Auction a) ORDER BY i.itemId ASC";

	PreparedStatement auctionPS = conn.prepareStatement(cmd);
	auctionPS.setInt(1, userId);
	auctionPS.setInt(2, 0);
	ResultSet auctionRS = auctionPS.executeQuery();
	
	// move ids into an ArrayList
	ArrayList<Integer> itemIdList2 = new ArrayList<Integer>();
	ArrayList<Integer> auctionIdList = new ArrayList<Integer>();
	ArrayList<String> endingDateTimeList = new ArrayList<String>();
	while(auctionRS.next()){
		itemIdList2.add(auctionRS.getInt("itemId"));
		auctionIdList.add(auctionRS.getInt("auctionId"));
		endingDateTimeList.add(auctionRS.getString("endingDateTime"));
	}
	int numAuctions = 0;
	for (int i = 0; i < auctionIdList.size(); i++){
		int auctionId = auctionIdList.get(i);
		if (!DateCheck.isLiveAuction(endingDateTimeList.get(i)) ){
			continue;
		}
		numAuctions++;
	}
	
	if(itemIdList2.size() == 0 || numAuctions == 0){
		%>
		You have no items that currently have auctions
		<%
	}
	else{
		%>
		ItemId 		Item Information
		<br>
		<%
		// create an arraylist of strings where each string is a row in the displayed items list
		ArrayList<String> rows2 = new ArrayList<String>();
		for(int i = 0; i < itemIdList2.size(); i++){
			if (!DateCheck.isLiveAuction(endingDateTimeList.get(i)) ){
				Auction.endAuction(auctionIdList.get(i), conn);
				continue;
			}
			String row2 = createRow(itemIdList2.get(i), conn);
			rows2.add(row2);
		}
		for(int i = 0 ; i < rows2.size(); i++){
			out.print(rows2.get(i) + "<br>");
		}
	}
	
	
	// close connection
	db.closeConnection(conn);
	
	%>
	
	<br>
	<br>
	<a href = "itemSubCat.jsp">Create a New Item</a>
	<br><br>
	<form method = "post" action = "account.jsp">
		<input type = "submit" value = "Back">
	</form>
	
<%	
}catch(Exception e){
	out.print(e);
}

%>
</body>
</html>