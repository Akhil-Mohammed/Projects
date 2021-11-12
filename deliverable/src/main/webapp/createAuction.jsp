<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Create Auction</title>
</head>
<body>
Enter Auction Information:
<br>
<%
try{
	// should not happen
	if(session == null){
		response.sendRedirect("index.jsp");
	}
	if(session.getAttribute("userId") == null){
		response.sendRedirect("index.jsp");
	}
	// only endUsers can make auctions
	String userTable = (String) session.getAttribute("userTable");
	if (userTable == null || !userTable.equals("endUser")){
		response.sendRedirect("account.jsp");
	}
	
	String itemid = request.getParameter("items");
	if (itemid == null || itemid.isEmpty()){
		response.sendRedirect("userItems.jsp");
	}
	else{
		Integer itemId = Integer.valueOf(itemid);
		// create auction for item
		
		// ask user to fill out auction information
		
	   %>
	   <form method ="post" action = "addAuction.jsp">
	   	<label for = "auctionName">Auction Name</label>
	   	<input type ="text" id = "auctionName" name = "auctionName">
	   	<br>
	   	<label for = "description">Auction Description</label>
	   	<input type ="text" id = "description" name = "description">
	   	<br>
	   	<label for = "minReserve">Reserve Price</label>
	   	<input type = "number" id = "minReserve" name = "minReserve" step = "0.01">
	   	<br>
	   	<label for = "startPrice">Starting Price</label>
	   	<input type = "number" id = "startPrice" name = "startPrice" step = "0.01">
	   	<br>
	   	<label for= "incPrice">Increment Price</label>
	   	<input type = "number" id = "incPrice" name = "incPrice" step = "0.01">
	   	<br>
	   	<label for = "endTime">Auction End</label>
	   	<input type = "datetime-local" id = "endTime" name = "endTime" required>
	   	<br>
	   	<script>
		   	var today = new Date();
		   	var day = today.getDate(); // auction must last until next day
		   	var month = today.getMonth() + 1;
		   	var year = today.getFullYear();
		   	if(day < 10){
		   		day = '0' + day;
		   	}
		   	if(month < 10){
		   		month = '0' + month;
		   	}
		   	today = year + '-' + month + '-' + day + "T00:00:00";
		   	document.getElementById("endTime").min = today;
	   	</script>
	   	<input type = "hidden" id= "itemId" name = "itemId" value = <%= itemId %>>
	   	<input type = "submit" value = "Create Auction">
	   </form>

	   <%
	   
	   String error = request.getParameter("error");
	   
	   if(error != null){
		   if(error.equals("invalidName")){
			   out.print("<span> Please Enter a Valid Auction Name </span>");
			   out.print("<br>");
		   }
		   if(error.equals("invalidDescription")){
			   out.print("<span> Please Enter a Valid Description</span>");
			   out.print("<br>");
		   }
		   if(error.equals("invalidPrice")){
	   			out.print("<span> Please Enter Valid Prices </span>");
				out.print("<br>");
		   }
		   if(error.equals("invalidDate")){
	   			out.print("<span> Please Select a Valid Date </span>");
				out.print("<br>");
	   		}
		   /*
		   if(error.equals("printDate")){
			   out.print("<span>" + request.getParameter("date") + "</span>");
			   out.print("<br>");
		   } */
		   
	   }
	   
	   
	}
	%>
	<br>
	<a href ="userItems.jsp">Back</a>
	<%
	
} catch(Exception e){
	out.print(e);
}



%>


</body>
</html>