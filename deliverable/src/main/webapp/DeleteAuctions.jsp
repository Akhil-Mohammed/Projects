<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>

<html>
<head
>
<meta charset="UTF-8">
<title>Auction:  Delete Auction </title>
</head>
<body>
	<%
	try 
	
			{
		
		if
		
		 (session.getAttribute("User Table") == null) || (session.getAttribute("User_ID") == null) 
		
				{
			response.sendError(404, request.getRequestURI());
			return;
		}
		else {
			String User_T = (String) session.getAttribute("User Table");
			
			if (User_T.equals("admin")) {
				out.print("<span> only for customerSupport </span>");
				return;
			}
			else if (User_T.equals("End User")) {
				response.sendError(404, request.getRequestURI());
				return;
			}
		}
	}
	
	
	catch(Exception e){
		out.print(e);
		return;
	}
	
	ArrayList<auctions> a1 = Auction.getAuctions();
	
	//calling auctions
	
	if (a1 == null) {
		out.print("An error occurred. Please try again");
	}
	else {
			
		if (request.getParameter("action") != null) 
			
				{
			int designatedID = Integer.parseInt(request.getParameter("AuctionID"));
			
			String action = request.getParameter("action");
			
			
			Auction designatedAuction = null;
			
			
			for (Auction a1: a) 
			
					{
				if (a1.getId() == designatedID) 
				
							{
					designatedAuction = a1;
					
					break;
				}
			}
			
			if 
				(designatedAuction == null) 
			//selecting auctions 
				{
				out.print("Auction "+designatedID+" nonexistent");
					
				out.print("<br>");
			}
			else 
			
					{
				if (action.equals("Remove")) 
				
						{
					
					if (designatedAuction.delete()) 
					
					
					
							{
						int index = a.indexOf(designatedAuction);
						
								a.remove(index);
						
						out.print("Deleted auction "+designatedID);
						
						out.print("<br>");
					}
					
						
						else 
					
							{
						
							out.print("Unable to remove auction "+designatedID);
								
						out.print("<br>");
					}
						
				}
				else if 
				(action.equals("Bids")) 
						{
					
					
					%>
					<form id="redirect" method="post" action="DeleteBids.jsp">
						
						<input name="AuctionID" hidden value=<%=designatedID%> />
						
					</form>
					
					<script>document.getElementById("redirect").submit();
					
					</script>
					<%
					return;
				}
			}
		}
		
		if (a.size() == 0) 
		
		{
			out.print("No auctions are there");
		}
		
		//selecting bids 
		
		
		else {
			for (Auction a1 : a)
			
			{
				%>
				<form method="post">
					<input name="AuctionID" hidden value=<%=a1.getId()%> />
					<h3>Auction <%=a1.getId()%></h3>
					
					<p>Name: <%=a1.getName()%></p>
					
					<input type="submit" name="action" value="remove" />
					
					<input type="submit" name="action" value="bids" />
					
				</form>
				
				<%
			}
		}
	}
	%>
</body>
</html>