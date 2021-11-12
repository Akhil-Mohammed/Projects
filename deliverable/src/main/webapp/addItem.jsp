<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Auction Site | Add Item</title>
</head>
<body>
<%!
public boolean emptyFields(ArrayList<String> Attributes, HttpServletRequest request){ // checks if user entered item name/attributes
	if(request.getParameter("itemName") == null || request.getParameter("itemName").trim().isEmpty()){
		return true;
	}
	for(String field: Attributes){
		if(request.getParameter(field) == null || request.getParameter(field).trim().isEmpty()){
			return true;
		}
	}
		
	return false;
}


public boolean invalidFieldLength(ArrayList<String> Attributes, HttpServletRequest request){
	final int MAX_NAME_LEN = 100;
	final int MAX_ATTR_LEN = 100;
	if(request.getParameter("itemName") == null ||  
		request.getParameter("itemName").length() > MAX_NAME_LEN){
		return true;
	}
	for(String field: Attributes){
		if(request.getParameter(field) == null || request.getParameter(field).length() > MAX_ATTR_LEN){
			return true;
		}
	}
	return false;
}

public boolean invalidFieldType(ArrayList<String> Attributes, ArrayList<String> Domains, HttpServletRequest request){
	
	for(int i = 0; i < Attributes.size(); i++){
		String attrVal = request.getParameter(Attributes.get(i));
		if(Domains.get(i).equals("int")){
			try{
				Integer val = Integer.parseInt(attrVal);
			} catch(NumberFormatException e){
				return true;
			}	
		}
		if(Domains.get(i).equals("double")){
			try{
				Double val = Double.parseDouble(attrVal);
			} catch(NumberFormatException e){
				return true;
			}
		}
		if(Domains.get(i).equals("boolean")){
			if(!attrVal.toLowerCase().equals("true") && !attrVal.toLowerCase().equals("false")){
				return true;
			}
		}
	}
	
	return false;
	
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
	
	Integer userId = (Integer)session.getAttribute("userId");
	String itemName = request.getParameter("itemName");
	
	
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
	
	// give item all of its attributes
	
	String subCatType = request.getParameter("subcat"); 
	if(subCatType == null || subCatType.isEmpty()){
		response.sendRedirect("itemSubCat.jsp");
	}
	String str1 = "SELECT name, domain FROM AttributeName WHERE catname = ? ";
	PreparedStatement ps = conn.prepareStatement(str1);
	ps.setString(1, subCatType);
	ResultSet rs = ps.executeQuery();
	
	// move attribute names to arraylist
	
	ArrayList<String> attributes = new ArrayList<String>();
	ArrayList<String> domains = new ArrayList<String>();
	while(rs.next()){
		attributes.add(rs.getString("name"));
		domains.add(rs.getString("domain"));
	}
	
	// check if attributes have been filled out
	if(emptyFields(attributes, request)){
		%>
	
		<form id = "errorRedirect" method = "post" action = "enterItemInfo.jsp?error=emptyFields"  >
			<input type = "hidden" name = "subcat" value = "<%= subCatType %>" >
		</form>
		<script>document.getElementById("errorRedirect").submit();</script>
		<% 	
	}
	else if(invalidFieldLength(attributes, request)){
		%>
		<form id = "fieldLengthRedirect" method = "post" action = "enterItemInfo.jsp?error=invalidFieldLength">
			<input type = "hidden" name = "subcat" value = "<%= subCatType %>" >
		</form>
		<script>document.getElementById("fieldLengthRedirect").submit();</script>
		<% 
	}
	else if(invalidFieldType(attributes, domains, request)){
		%>
		<form id = "fieldTypeRedirect" method = "post" action = "enterItemInfo.jsp?error=invalidFieldType">
			<input type = "hidden" name = "subcat" value = "<%= subCatType %>" >
		</form>
		<script>document.getElementById("fieldTypeRedirect").submit();</script>
		
		<%
	}
	else{
		// add item to items table
		String insertItem = "INSERT into Item (userId, name) values (?,?)";
		PreparedStatement preparedstmt = conn.prepareStatement(insertItem);
		preparedstmt.setInt(1, userId);
		preparedstmt.setString(2, itemName);
		preparedstmt.executeUpdate();
		
		// fetch itemid of item just inserted into the table 
		// (will have max itemid of all items in the table)
		
		String str2 = "SELECT itemId from Item where itemId = (SELECT max(itemID) from Item)";
		Statement maxstmt = conn.createStatement();
		ResultSet rsMax = maxstmt.executeQuery(str2);
		Integer itemId = 0;
		// fix error check later
		if(!rsMax.next()){ // should not happen because item was just inserted
			out.print("<span>No items in Item</span>" );
		}
		else{
			itemId = rsMax.getInt("itemId");
		}
		
		
		for(String attribute: attributes){
			String attrVal = request.getParameter(attribute);
			String insertAttr = 
				"INSERT into ItemAttribute (attributeValue, itemId, name, catName) Values (?,?,?,?)";
			PreparedStatement attrPS = conn.prepareStatement(insertAttr);
			attrPS.setString(1, attrVal);
			attrPS.setInt(2, itemId);
			attrPS.setString(3, attribute);
			attrPS.setString(4, subCatType);
			attrPS.executeUpdate();
		}
			
		response.sendRedirect("userItems.jsp");
		
		
	}
	
	
} catch(Exception e){
	out.print(e);
}




%>


</body>
</html>