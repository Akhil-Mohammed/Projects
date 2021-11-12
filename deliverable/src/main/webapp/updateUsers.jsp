<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Auction Site | Update Users</title>
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
			
			if (userTable.equals("administrator")) {
				out.print("<span>This service is for customer support</span>");
				return;
			}
			else if (userTable.equals("endUser")) {
				response.sendError(404, request.getRequestURI());
				return;
			}
		}
	}
	catch(Exception e){
		out.print(e);
		return;
	}
	
	// process request
	
	ArrayList<EndUser> users = EndUser.getEndUsers();

	if (users == null) {
		out.print("<span>An error occurred. Please try again.</span>");
	}
	else {
		if (request.getParameter("action") != null) {
			int selectedId = Integer.parseInt(request.getParameter("userId"));
			String action = request.getParameter("action");
			
			if (action.equals("Update")) {
				EndUser selectedUser = null;
				for (EndUser user : users) {
					if (user.getId() == selectedId) {
						selectedUser = user;
						break;
					}
				}
				
				if (selectedUser == null) {
					out.print("User not found");
				}
				else {
					String email = request.getParameter("email");
					String password = request.getParameter("password");
					String firstName = request.getParameter("firstName");
					String lastName = request.getParameter("lastName");
					
					boolean actionAllowed = true;
					actionAllowed = actionAllowed && (ValueValidation.isValidName(firstName) && ValueValidation.isValidName(lastName));
					actionAllowed = actionAllowed && ValueValidation.isValidPassword(password);
					if (actionAllowed) {
						ApplicationDB db = new ApplicationDB();
						Connection con = db.getConnection();
						actionAllowed = con != null;
						if (actionAllowed) {
							String[] tables = new String[] { "endUser", "administrator", "customerSupport" };
							for (String table : tables) {
								if (ValueValidation.tableHasEmail(con, table, email, selectedId)) {
									actionAllowed = false;
									break;
								}
							}
							db.closeConnection(con);
						}
					}
					
					if (actionAllowed) {
						selectedUser.setFirstName(firstName);
						selectedUser.setLastName(lastName);
						selectedUser.setEmail(email);
						selectedUser.setPassword(password);
					}
					else {
						out.print("Invalid parameter");
					}

				}
			}
			else if (action.equals("Delete")) {
				EndUser selectedUser = null;
				for (EndUser user : users) {
					if (user.getId() == selectedId) {
						selectedUser = user;
						break;
					}
				}
				
				if (selectedUser == null) {
					out.print("User not found");
				}
				else {
					if (EndUser.deleteUser(selectedId)) {
						int index = users.indexOf(selectedUser);
						users.remove(index);
						out.print("Deleted user "+selectedId);
						out.print("<br>");
					}
					else {
						out.print("Could not delete user "+selectedId);
					}
				}
			}
		}
		
		if (users.size() == 0) {
			out.print("No users exist");
		}
		for (EndUser user : users) {
			int userId = user.getId();
			%>
			<h3>User <%=userId%></h3>
			<form method="post">
				<label for="email<%=userId%>">E-Mail</label>
				<input required id="email<%=userId%>" name="email" type="email" value=<%=user.getEmail()%> />
				<br>
				<label for="password<%=userId%>">Password</label>
				<input required id="password<%=userId%>" name="password" type="text" value=<%=user.getPassword()%> />
				<br>
				<label for="firstName<%=userId%>">First Name</label>
				<input required id="firstName<%=userId%>" name="firstName" type="text" value=<%=user.getFirstName()%> />
				<br>
				<label for="lastName<%=userId%>">Last Name</label>
				<input required id="lastName<%=userId%>" name="lastName" type="text" value=<%=user.getLastName()%> />
				<br>
				<input name="userId" value=<%=userId %> hidden />
				<input name="action" type="submit" value="Update" />
				<input name="action" type="submit" value="Delete" />
			</form>
			<%
		}
	}
	%>
</body>
</html>