<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.math.BigDecimal"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>


<!DOCTYPE html>


<html>
<head>
<meta charset="UTF-8">



<title> Auction: Deleting the bids </title>

</head>
<body>
	<%
	try {
		
		
		if 
		
		(session.getAttribute("User Table")== null|| session.getAttribute("UserID")== null 
		
		) 
			
				{
			
					response.sendError(404, request.getRequestURI());
			
					
					
					return;
		}
		else 
				{
			
			
				String User_T = (String) session.getAttribute("User_Table");
			
				if 
				(User_T.equals("admin")) 
				
						{
					out.print
					
					
					(
							"<span>Meant only for customerSupport</span>"
							);
							
							return;
				}
				
				
				else if (User_T.equals("End User")) 
			
			{
				response.sendError(404, request.getRequestURI());
				return;
			}
			
			
				}
		}
	
	
	catch(Exception e)
			
			{
		out.print(e);
		return;
		
		}
	
	
			ArrayList<Auction> a = Auction.getAuctions();
	
	if (a == null) 
				{
				out.print("Error. Try again");
	}
	
			else 
				{
		if (request.getParameter("Auction_ID") 
				== null) 
		
				{
			response.sendRedirect("removeAuction.jsp");
			return;
		}
		
				int designatedID= Integer.parseInt
								
							(request.getParameter("auctionId"));
		
		Auction designatedauc= null;
		
			
				for (Auction a1: a) 
				
				
						{
						
				if (a1.getId()== designatedID) 
					
				{
						
				designatedauc= a1;
				
				break;
				}
			}
				
				
		
		if(designatedauc== null) 
				{
			
				response.sendRedirect("removeAuction.jsp");
			
			
				return;
		}
		
	
		
		ArrayList<Bid> b= Bid.getBids(designatedID);
		
		
		if (b == null) 
					{
			
			out.print("Error. Please try again");
					
			return;
			}
		
			if (request.getParameter("sum")!= null) 
				
					{
			
				String string_sum = request.getParameter("sum");
				
					BigDecimal sum = new BigDecimal(string_sum); 
					
			
			boolean remove= Bid.deleteBid(designatedID, sum);
			
			if (remove) 
			
						{
					
				out.print("Bid successfully removed");
				
				out.print("<br/>");
			
				

				
				int k=0;
				//using loops
				while (k< b.size())
				{
					
					if (b.get(k).getAmount().equals(sum)) {
						b.remove(k);
						break;
						
					}
					k++;
					
					
				}
			}
			//deleting bids
						
						
			else {
							
					out.print("Unable to remove bid");
					
					out.print("<br/>");
				
			}
		}
		
		out.print("<h3>Auction "+designatedID+"</h3> <br>");
		
		if (b.size() == 0) 
				{
			out.print("There aren't any bids present");
		}
		else {
			for (Bid b1 : b) {
				//bid amounts
				%>
				<form method="post">
					<input name="Auction_ID" hidden value=<%=designatedID%> />
					
					<input name="sum" hidden value=<%=b1.getAmount().toString()%> />
					
					<p> User_ID: <%=b1.getUserId()%> </p>
					
					<p> Amount: <%=Prices.formatPrice(b1.getAmount().floatValue())%> </p>
					<input type="submit" name="action" value="remove" />
					
				</form>
				<%
			}
		}
	}
	%>
	</body>
	
</html>