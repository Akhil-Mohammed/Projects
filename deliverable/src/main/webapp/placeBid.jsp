<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Place a Bid</title>
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
	// user selected an auction from the previous page
	String auctionID = request.getParameter("auctionId");
	if(auctionID == null || auctionID.isEmpty() ){
		response.sendRedirect("account.jsp");
	}
	Integer auctionId = Integer.parseInt(auctionID);
	
	
	
	
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection conn = db.getConnection();
	
	// query auction + item table to make sure item has not been sold
	
	String getIsSold = "SELECT i.itemStatus itemStatus FROM Auction a, Item i WHERE a.itemId = i.itemId AND a.itemId = (SELECT itemId FROM Auction WHERE auctionId = ?)";
	PreparedStatement auctionGIS = conn.prepareStatement(getIsSold);
	auctionGIS.setInt(1, auctionId);
	ResultSet auctionRIS = auctionGIS.executeQuery();
	if(!auctionRIS.next()){
		response.sendRedirect("account.jsp");
		return;
	}
	else{
		if(!auctionRIS.getString("itemStatus").equals("0")){
			response.sendRedirect("account.jsp");
			return;
		}
	}
	
	// query auction table to make sure user can't bid on their own auction
	String getSeller = "SELECT i.userId userId FROM Auction a, Item i WHERE a.itemId = i.itemId AND a.itemId = (SELECT itemId FROM Auction WHERE auctionId = ?)";
	PreparedStatement auctionGS = conn.prepareStatement(getSeller);
	auctionGS.setInt(1, auctionId);
	ResultSet auctionRS = auctionGS.executeQuery();
	if(!auctionRS.next()){
		response.sendRedirect("account.jsp");
		return;
	}
	else{
		if(auctionRS.getInt("userId") == userId){
			response.sendRedirect("account.jsp");
			return;
		}
	}
	
	// query auction to see if it is unclosed but the current time is > than closing time
	String getEndTime = "SELECT endingDateTime FROM Auction where auctionId = ?";
	PreparedStatement auctionEndStmt = conn.prepareStatement(getEndTime);
	auctionEndStmt.setInt(1, auctionId);
	ResultSet endTimeRS = auctionEndStmt.executeQuery();
	endTimeRS.next();
	String endingTime = endTimeRS.getString("endingDateTime");
	endingTime = endingTime.substring(0, endingTime.length() - 2);
	if (!DateCheck.isLiveAuction(endingTime)){ // auction is past closing time
		Auction.endAuction(auctionId, conn);
		response.sendRedirect("fullAuctionListing.jsp");
		return;
	}
	
	// query to get highest auction bid (may change after insert)
	String getCurrentMax = "SELECT amount FROM Bid WHERE auctionId = ? AND amount IN (SELECT max(amount) FROM Bid WHERE auctionId = ? GROUP BY auctionId)";
	PreparedStatement auctionGCM = conn.prepareStatement(getCurrentMax);
	auctionGCM.setInt(1, auctionId);
	auctionGCM.setInt(2, auctionId);
	ResultSet auctionRCM = auctionGCM.executeQuery();
	String highestBid = "";
	
	if (!auctionRCM.next()){ // no bids placed yet
		highestBid = "0.00";
	}
	else{
		highestBid = auctionRCM.getString("amount");
	}
	// query to get auction name
	String getName = "SELECT auctionName FROM Auction WHERE auctionId = ? ";
	PreparedStatement auctionGN = conn.prepareStatement(getName);
	auctionGN.setInt(1, auctionId);
	ResultSet auctionRN = auctionGN.executeQuery();
	auctionRN.next();
	String auctionName = auctionRN.getString("auctionName");
	
	// query to get startPrice and incPrice
	
	String getRequired = "SELECT startPrice, incPrice from Auction where auctionid = ?";
	PreparedStatement auctionGR = conn.prepareStatement(getRequired);
	auctionGR.setInt(1, auctionId);
	ResultSet auctionRR = auctionGR.executeQuery();
	auctionRR.next();
	double startPrice = Double.parseDouble(auctionRR.getString("startPrice"));
	double incPrice = Double.parseDouble(auctionRR.getString("incPrice"));
	
	// check if bid is valid
	
	double highestBidAmount = Double.parseDouble(highestBid);
	String bid = request.getParameter("bidAmount");
	if(bid != null && !bid.isEmpty()){
		double bidAmount = Double.parseDouble(bid);
		
		if (Prices.isValidPrice(bid) && Prices.isValidBid(bidAmount, startPrice, highestBidAmount, incPrice)){ // bid entered into Bid table
			// find string for current datetime
			SimpleDateFormat format = new SimpleDateFormat("YYYY-MM-dd HH:mm:ss");
			String currDateTime = format.format(new java.util.Date());
			
			// query to insert into bids table
			String stmt = "INSERT into Bid(amount, bidDateTime, auctionId, userId) VALUES(?,?,?,?)";
			PreparedStatement ps = conn.prepareStatement(stmt);
			ps.setDouble(1, Prices.getPrice(bid));
			ps.setString(2, currDateTime);
			ps.setInt(3, auctionId);
			ps.setInt(4, userId);
			int status = ps.executeUpdate();
			
			// get all other buyers involved in auction
			String getBuyers = "SELECT distinct userId FROM Bid WHERE auctionId = ? AND userId <> ?";
			PreparedStatement auctionGB = conn.prepareStatement(getBuyers);
			auctionGB.setInt(1, auctionId);
			auctionGB.setInt(2, userId);
			ResultSet auctionRB = auctionGB.executeQuery();
			ArrayList<String> buyerIds = new ArrayList<String>();
			while (auctionRB.next()){
				buyerIds.add(auctionRB.getString("userId"));
			}
			String alertMessage = "A user has placed a new higher bid of " + Prices.formatPrice(Prices.getPrice(bid)) + " on auction: " + auctionName;
			for(int i = 0; i < buyerIds.size(); i++){
				String buyerID = buyerIds.get(i);
				Integer buyerId = Integer.parseInt(buyerID);
				String insertAlert = "INSERT into Alert (userId, alertMessage, alertDateTime) VALUES (?, ?, ?)";
				PreparedStatement auctionIA = conn.prepareStatement(insertAlert);
				auctionIA.setInt(1, buyerId);
				auctionIA.setString(2, alertMessage);
				auctionIA.setString(3, currDateTime);
				int messageStatus = auctionIA.executeUpdate();
			}
			
		}
		else{
			out.print("<span>Please Enter a Valid Bid</span>");
			out.print("<br>");
		}
	}
	
	out.print("Place A Bid for Auction: " + auctionName );
	out.print("<br>");
	
	// query to get highest auction bid (may change after insert)
	String getMax = "SELECT amount FROM Bid WHERE auctionId = ? AND amount IN (SELECT max(amount) FROM Bid WHERE auctionId = ? GROUP BY auctionId)";
	PreparedStatement auctionGM = conn.prepareStatement(getMax);
	auctionGM.setInt(1, auctionId);
	auctionGM.setInt(2, auctionId);
	ResultSet auctionRM = auctionGM.executeQuery();

	double minBid;
	// no bids yet
	if(!auctionRM.next()){
		String starting = auctionRR.getString("startPrice");
		out.print("The Current Auction Has No Bids Placed, The Starting Price is: " + Prices.formatPrice(Prices.getPrice(starting)));
		out.print("<br>");
		minBid = Prices.getPrice(starting);
		if (minBid == 0){
			minBid = 0.01;
		}
		
	}
	// current highest bid
	else{
		highestBid = auctionRM.getString("amount");
		//highestBid = Double.parseDouble(auctionMax);
		out.print("The Current Highest Bid is: " + Prices.formatPrice(Prices.getPrice(highestBid)));
		out.print("<br>");
		minBid = Prices.getPrice(highestBid) + incPrice;
	}
	out.print("Please enter a bid of " + Prices.formatPrice(minBid) + " or greater");
	 
	%>
	<form method = "post" action = "placeBid.jsp">
		<input type = "hidden" name = "auctionId" value = "<%= auctionId %>">
		<br>
		<label for= "bidAmount">Bid Amount</label>
		<input type = "number" id = "bidAmount" name = "bidAmount" step = "0.01">
		<br>
		<input type = "submit" value = "Place Bid">
	</form>
	<br><br>
	<form method = "post" action = "account.jsp">
		<input type = "submit" value = "Back">
	</form>
	
	<%
	db.closeConnection(conn);
} catch (Exception e){
	out.print(e);
}


%>
</body>
</html>