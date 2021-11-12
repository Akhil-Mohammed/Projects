<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Select Item Type</title>
</head>
<body>

<%
try{
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection conn = db.getConnection();
		
	if (conn == null) {
		System.out.println("Could not connect to database");
		out.print("Could not connect to database");
		response.sendRedirect("index.jsp?error=failed");
	}
	
	String userTable = (String) session.getAttribute("userTable");
	if (userTable == null || !userTable.equals("endUser")){
		response.sendRedirect("account.jsp");
	}
	
	// Query the subcategory type names from the SubCategory table
	
	String str = "SELECT name from SubCategoryType";
	Statement stmt1 = conn.createStatement();
	ResultSet rs1 = stmt1.executeQuery(str);
	
	// create an ArrayList
	ArrayList<String> subCatList = new ArrayList<String>();
	
	while(rs1.next()){
		subCatList.add(rs1.getString("name"));
	}
	
	db.closeConnection(conn);
	%>
	Select the Item's Sub-Category Type:
	<br>
	
	<form method="post" action = "enterItemInfo.jsp">
	<%
	for(int i = 0; i < subCatList.size(); i++){
		String catName = subCatList.get(i);
	%>
		<input type = "radio" id= <%=catName %> name = "subcat" value = <%=catName %> 
		<% if (i == 0) out.print("checked"); %> >
		<label for = <%=catName %>><%=catName %></label>
		<br>
		
		 <% 
	}
	
	

	%>
	<input type = "submit" value = "Confirm" >
	</form>
	<%
} catch(Exception e){
	out.print(e);
}
%>


</body>
</html>