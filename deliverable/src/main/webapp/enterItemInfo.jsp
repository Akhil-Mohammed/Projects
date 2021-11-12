<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Enter Item Information</title>
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
	
	String subCatType = request.getParameter("subcat"); 
	if(subCatType == null || subCatType.isEmpty()){
		response.sendRedirect("itemSubCat.jsp");
	}
	String str1 = "SELECT name from AttributeName where catname = ? ";
	PreparedStatement ps = conn.prepareStatement(str1);
	ps.setString(1, subCatType);
	
	
	ResultSet rs = ps.executeQuery();
	
	// move attribute names to arraylist
	
	ArrayList<String> attributes = new ArrayList<String>();
	while(rs.next()){
		attributes.add(rs.getString("name"));
	}
	db.closeConnection(conn);
	%>
	
	Item Type: <%out.print(subCatType); %>
	
	<form method= "post" action = "addItem.jsp" >
	<label for="itemName" >Item Name</label>
	<input type="text" id= "itemName" name= "itemName" >
	<input type="hidden" id="subcat" name="subcat" value= "<%=subCatType %>">
	<br>
	<% 
	for(String attribute: attributes){ %>
		<label for= <%=attribute %> > <%=attribute %> </label>
		<input type= "text" id= "<%=attribute%>" name= "<%=attribute%>" > 
		<br>
		<%	
					
	}
	%>
	<input type="submit" value="Add Item">
	</form>	
	
	<% 
	String error = request.getParameter("error");
	if(error != null){
		if(error.equals("emptyFields")){
			out.print("<span>Please fill out all fields</span>");
		}
		if(error.equals("invalidFieldLength")){
			out.print("<span>Invalid fields:</span>");
			out.print("<br>");
			out.print("<span>Please keep name length <= 50 and attribute length <= 100</span>");
		}
		if(error.equals("invalidFieldType")){
			out.print("<span>Invalid fields:</span>");
			out.print("<br>");
			out.print("<span>Please fill out fields with their proper type</span>");
		}
			
	}
} catch(Exception e){
	out.print(e);
}
%>
</body>
</html>