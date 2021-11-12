<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="ISO-8859-1">
	<title>Auction Site | Sales Report</title>
	<style>
		.table-name {
			font-weight: bold;
		}
	</style>
</head>
<body>
	<%
		try {
			// if user is not an authorized admin, show 404 error
			if (session.getAttribute("userId") == null || session.getAttribute("userTable") == null) {
				response.sendError(404, request.getRequestURI());
				return;
			}
			else {
				String userTable = (String) session.getAttribute("userTable");
				
				if (!userTable.equals("administrator")) {
					response.sendError(404, request.getRequestURI());
					return;
				}
			}
		}
		catch(Exception e){
			out.print(e);
			return;
		}

		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();
	
		if (con != null) {
			try {
				ArrayList<String> itemTypes = SoldItem.getItemTypes(con);
				ArrayList<SoldItem> items = SoldItem.getSoldItems(con);

				db.closeConnection(con);
				
				// best selling
				Map<Integer, Integer> bestBuyers = new HashMap<Integer, Integer>();
				Map<String, Integer> bestItems = new HashMap<String, Integer>();
				
				// earnings
				Map<Integer, Double> sellerEarnings = new HashMap<Integer, Double>();
				Map<String, Double> itemEarnings = new HashMap<String, Double>();
				Map<String, Double> itemTypeEarnings = new HashMap<String, Double>();
				double totalEarnings = 0;

				for (String itemType : itemTypes) { itemTypeEarnings.put(itemType, 0.0); }
				
				for (SoldItem item : items) {
					// earnings
					totalEarnings += item.getPrice();
					
					double prevS = sellerEarnings.getOrDefault(item.getSellerId(), 0.0);
					sellerEarnings.put(item.getSellerId(), prevS+item.getPrice());
					
					double prevI = itemEarnings.getOrDefault(item.getName(), 0.0);
					itemEarnings.put(item.getName(), prevI+item.getPrice());
					
					double prevIT = itemTypeEarnings.getOrDefault(item.getType(), 0.0);
					itemTypeEarnings.put(item.getType(), prevIT+item.getPrice());
					
					// best selling
					int prevB = bestBuyers.getOrDefault(item.getBuyerId(), 0);
					bestBuyers.put(item.getBuyerId(), prevB+1);

					int prevSI = bestItems.getOrDefault(item.getName(), 0);
					bestItems.put(item.getName(), prevSI+1);
				}

				bestBuyers = Generic.getSortedMap(bestBuyers, true);
				bestItems = Generic.getSortedMap(bestItems, true);
				sellerEarnings = Generic.getSortedMap(sellerEarnings, true);
				itemEarnings = Generic.getSortedMap(itemEarnings, true);
				itemTypeEarnings = Generic.getSortedMap(itemTypeEarnings, true);

				int rank = 1;
				%>
				<p class="table-name">Total Earnings: <%=Prices.formatPrice(totalEarnings)%></p>
				
				<span class="table-name">Seller Earnings</span>
				<table>
					<tr>
						<th>Ranking</th>
						<th>User ID</th>
						<th>Net Earnings</th>
					</tr>
					<%
					rank = 1;
					for (int sellerId : sellerEarnings.keySet()) {
						%>
						<tr>
							<td><%=rank++%></td>
							<td><%=sellerId%></td>
							<td><%=Prices.formatPrice(sellerEarnings.get(sellerId))%></td>
						</tr>
						<%
					}
					%>
				</table>
				
				<br/>
				
				<span class="table-name">Item Earnings</span>
				<table>
					<tr>
						<th>Ranking</th>
						<th>Item Name</th>
						<th>Net Earnings</th>
					</tr>
					<%
					rank = 1;
					for (String itemName : itemEarnings.keySet()) {
						%>
						<tr>
							<td><%=rank++%></td>
							<td><%=itemName%></td>
							<td><%=Prices.formatPrice(itemEarnings.get(itemName))%></td>
						</tr>
						<%
					}
					%>
				</table>
				
				<br/>
				
				<span class="table-name">Item Type Earnings</span>
				<table>
					<tr>
						<th>Ranking</th>
						<th>Item Type</th>
						<th>Net Earnings</th>
					</tr>
					<%
					rank = 1;
					for (String itemType : itemTypeEarnings.keySet()) {
						%>
						<tr>
							<td><%=rank++%></td>
							<td><%=itemType%></td>
							<td><%=Prices.formatPrice(itemTypeEarnings.get(itemType))%></td>
						</tr>
						<%
					}
					%>
				</table>
				
				<br/>
				
				<span class="table-name">Best-Selling Items</span>
				<table>
					<tr>
						<th>Ranking</th>
						<th>Item Name</th>
						<th>Total Sales</th>
					</tr>
					<%
					rank = 1;
					for (String itemName : bestItems.keySet()) {
						%>
						<tr>
							<td><%=rank++%></td>
							<td><%=itemName%></td>
							<td><%=bestItems.get(itemName)%></td>
						</tr>
						<%
					}
					%>
				</table>
				
				<br/>
				
				<span class="table-name">Best Buyers</span>
				<table>
					<tr>
						<th>Ranking</th>
						<th>User ID</th>
						<th>Total Auctions Won</th>
					</tr>
					<%
					rank = 1;
					for (int buyerId : bestBuyers.keySet()) {
						%>
						<tr>
							<td><%=rank++%></td>
							<td><%=buyerId%></td>
							<td><%=bestBuyers.get(buyerId)%></td>
						</tr>
						<%
					}
					%>
				</table>
				
				
				<br/>
				
				<span class="table-name">All Sales</span>
				<table>
					<tr>
						<th>Item Type</th>
						<th>Item ID</th>
						<th>Item Name</th>
						<th>Seller ID</th>
						<th>Buyer ID</th>
						<th>Sell Price</th>
					</tr>
					<%
					for (SoldItem item : items) {
						%>
						<tr>
							<td><%=item.getType()%></td>
							<td><%=item.getId()%></td>
							<td><%=item.getName()%></td>
							<td><%=item.getSellerId()%></td>
							<td><%=item.getBuyerId()%></td>
							<td><%=Prices.formatPrice(item.getPrice())%></td>
						</tr>
						<%
					}
					%>
				</table>
				
				<%
			} catch (SQLException e) {
				db.closeConnection(con);
				e.printStackTrace();
			}
		}
		else {
			out.print("An error occurred. Please try again");
		}
	%>
</body>
</html>