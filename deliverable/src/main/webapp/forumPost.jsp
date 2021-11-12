<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.text.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="ISO-8859-1">
	<title>Auction Site | Forum</title>
	<style>
	.replies {
	 	list-style-type: none;
	 	padding: 0;
		margin: 0;
	}
	.replies > li:not(:last-child) {
		margin: 0 0 10px 0;
	}
	</style>
</head>
<body>
	<%!
	int parseSelectedId(ServletRequest request) {
		if (request.getParameter("postId") == null) return -1;
		try {
			int postId = Integer.parseInt(request.getParameter("postId"));
			return postId;
		} catch (NumberFormatException e) { return -1; }
	}
	boolean createReply(int postId, int userId, String content, String userTable) {
		try {
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();
	
			if (con == null) {
				return false;
			}
			
			String table = userTable.equals("endUser") ? "ForumComment" : "ForumAnswer";
	
			String str = String.format("INSERT INTO %s (postId, content, userId) values (?, ?, ?);", table);
	
			PreparedStatement stmt = con.prepareStatement(str);
			stmt.setInt(1, postId);
			stmt.setString(2, content);
			stmt.setInt(3, userId);
			
			int addUserResult = stmt.executeUpdate();
			
			db.closeConnection(con);
			
			return true;
		} catch(Exception e) { 
			e.printStackTrace();
			return false; }
	}
	final int MAX_REPLY_LENGTH = 1000;
	%>
	
	
	<%
	int postId = parseSelectedId(request);
	if (postId > 0 && request.getParameter("content") != null) {
		String content = request.getParameter("content");
		// attempt to add post
		if (content.length() < MAX_REPLY_LENGTH && session.getAttribute("userId") != null && session.getAttribute("userTable") != null) {
			String userTable = (String) session.getAttribute("userTable");
			Integer userId = (Integer) session.getAttribute("userId");
			if (userTable.equals("endUser") || userTable.equals("customerSupport")) {
				createReply(postId, userId, content, userTable);
			}
		}
	}
	%>
	
	<h3>Welcome to the Forum!</h3>
	<a href="createForumPost.jsp">Create a new post</a>
	<br>
	
	<%
	ArrayList<ForumPost> forumPosts;
	if (request.getParameter("postId") != null) {
		%>
		<a href="forumPost.jsp">View all posts</a>
		<br>
		<% 
		forumPosts = ForumPost.getForumPosts(true);
		int selectedPostId = parseSelectedId(request);
		ForumPost selectedPost = null;
		for (ForumPost post : forumPosts) {
			if (post.getId() == selectedPostId) {
				selectedPost = post;
				break;
			}
		}
		
		if (selectedPost == null) {
			%>
			<span>This post does not exist</span>
			<%
		}
		else {
			// display post
			SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			%>
			<span style="font-weight: bold;">Made by:</span>
			<span>User <%= selectedPost.getUserId()%></span>
			<br>
			<span style="font-weight: bold;">Title:</span>
			<span><%=selectedPost.getTitle()%></span>
			<br>
			<span style="font-weight: bold;">Description:</span>
			<span><%=selectedPost.getDescription()%></span>
			<br>
			<p style="font-weight: bold;">Replies (<%=selectedPost.getReplies().size()%>):</p>
			<ul class="replies">
			<%
				for (ForumReply reply : selectedPost.getReplies()) {
					String creator = reply instanceof ForumAnswer ? "Customer Support" : "User";
					%>
					<li>
						<span><%= formatter.format(reply.getCreatedAt())%></span>
						<br>
						<span style="font-weight: bold;"><%=creator+" "+reply.getCreatorId()+":"%></span>
						<span><%=reply.getContent()%></span>
					</li>
					<%
				}
			%>
			</ul>
			<%
			
			// display reply box if enduser or customerSupport
			
			if (session.getAttribute("userId") != null && session.getAttribute("userTable") != null) {
				String userTable = (String) session.getAttribute("userTable");
				if (userTable.equals("endUser") || userTable.equals("customerSupport")) {
					%>
					<form action="forumPost.jsp" method="post">
						<textarea required maxlength=<%=MAX_REPLY_LENGTH%> name="content"></textarea>
						<br>
						<input name="postId" value=<%=selectedPost.getId()%> hidden/>
						<input type="submit" value="Add Reply"/>
					</form>
					<%
				}
			}
		}
	}
	else {
		forumPosts = ForumPost.getForumPosts(false);
		%>
		<span>Total Posts: <%=forumPosts.size()%></span>
		<br>
		<br>
		
		<label for="search-bar">Search:</label>
		<input id="search-bar" type="text"/>
		
		<br>
		<br>
		<%
		for (ForumPost forumPost : forumPosts) {
			%>
			<div class="post-link">
				<a href="forumPost.jsp?postId=<%=forumPost.getId()%>">
					<%=forumPost.getTitle()%>
				</a>
				<br>
			</div>
			<%
		}
	}
	%>
	
	<script>
	function attachSearch() {
		// find search bar
		var searchBar = document.getElementById("search-bar");
		
		// attach listener for "keyup" event
		// event is triggered when key on keyboard is lifted
		searchBar.addEventListener('keyup', function (event) {
			// get current value of search bar
			var value = searchBar.value.trim().toLowerCase();
			
			// get all posts
			var posts = document.getElementsByClassName("post-link");
			
			// if there is a value
			if (value) {
				// show all posts that contain the value
				for (var i = 0; i < posts.length; i++) {
					var postText = posts[i].innerText.trim().toLowerCase();
					posts[i].style.display = postText.indexOf(value) >= 0 ? 'inline' : 'none';
				}
			}
			// if there is no value (empty search bar)
			else {
				// display all posts
				for (var i = 0; i < posts.length; i++) {
					posts[i].style.display = 'inline';
				}
			}
		});
	}
	attachSearch();
	</script>
</body>
</html>