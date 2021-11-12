package com.cs336.pkg;

import java.util.ArrayList;
import java.util.Date;

import java.sql.*;

public class ForumPost {
	private int postId, userId;
	private String title, description;
	private Date createdAt;
	private ArrayList<ForumReply> replies;

	public ForumPost(int postId, String title, String description, int userId, Date createdAt) throws Exception {
		this.postId = postId;
		this.userId = userId;
		this.title = title;
		this.description = description;
		this.createdAt = createdAt;
	}
	
	public void loadReplies() throws Exception {
		ArrayList<ForumAnswer> answers = new ArrayList<>();
		ArrayList<ForumComment> comments = new ArrayList<>();

		try {
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();
	
			if (con == null) {
				throw new NullPointerException();
			}
	
			String answerStr = "select * from ForumAnswer where postId = ?";
	
			PreparedStatement answerStmt = con.prepareStatement(answerStr);
			answerStmt.setInt(1, postId);
			
			ResultSet answerResults = answerStmt.executeQuery();
			
			while (answerResults.next()) {
				int answerId = answerResults.getInt("answerId");
				Date answerDate = answerResults.getTimestamp("created_at");
				String content = answerResults.getString("content");
				int csId = answerResults.getInt("userId");
				answers.add(new ForumAnswer(answerId, postId, csId, answerDate, content));
			}
			
			String commentStr = "select * from ForumComment where postId = ?";
			
			PreparedStatement commentStmt = con.prepareStatement(commentStr);
			commentStmt.setInt(1, postId);
			
			ResultSet commentResults = commentStmt.executeQuery();
			
			while (commentResults.next()) {
				int commentId = commentResults.getInt("commentId");
				Date commentDate = commentResults.getTimestamp("created_at");
				String content = commentResults.getString("content");
				int userId = commentResults.getInt("userId");
				comments.add(new ForumComment(commentId, postId, userId, commentDate, content));
			}

			db.closeConnection(con);
		} catch(Exception e) {
			e.printStackTrace();
			throw e;
		}
		
		insertIntoReplies(answers, comments);
	}
	
	private void insertIntoReplies(ArrayList<ForumAnswer> answers, ArrayList<ForumComment> comments) {
		replies = new ArrayList<ForumReply>();
		
		int i1 = 0, i2 = 0;
		int n1 = answers.size(), n2 = comments.size();
		
		while (i1 < n1 || i2 < n2) {
			if (i1 < n1 && i2 < n2) {
				ForumAnswer a = answers.get(i1);
				ForumComment c = comments.get(i2);
				int cmp = a.getCreatedAt().compareTo(c.getCreatedAt());
				if (cmp == 0) {
					replies.add(a);
					replies.add(c);
					i1++; i2++;
				}
				else if (cmp < 0) {
					replies.add(a);
					i1++;
				}
				else {
					replies.add(c);
					i2++;
				}
			}
			else if (i1 < n1) {
				for (int i = i1; i < n1; i++) {
					replies.add(answers.get(i));
				}
				i1 = n1;
			}
			else {
				for (int i = i2; i < n2; i++) {
					replies.add(comments.get(i));
				}
				i2 = n2;
			}
		}
	}
	
	public ArrayList<ForumReply> getReplies() {
		return replies;
	}
	
	public String getTitle() {
		return title;
	}

	public int getId() {
		return postId;
	}

	public int getUserId() {
		return userId;
	}

	public Date getCreatedAt() {
		return createdAt;
	}

	public String getDescription() {
		return description;
	}
	
	public static ArrayList<ForumPost> getForumPosts(boolean loadFull) {
		try {
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();
	
			if (con == null) {
				return null;
			}
	
			String str = "select * from ForumPost";
	
			PreparedStatement stmt = con.prepareStatement(str);
			
			ResultSet results = stmt.executeQuery();
			
			ArrayList<ForumPost> posts = new ArrayList<ForumPost>();
			
			while (results.next()) {
				int postId = results.getInt("postId");
				String title = results.getString("title");
				String description = results.getString("description");
				int userId = results.getInt("userId");
				Date createdAt = results.getTimestamp("created_at");
				
				ForumPost post = new ForumPost(postId, title, description, userId, createdAt);
				if (loadFull) {
					post.loadReplies();
				}
				posts.add(post);
			}

			db.closeConnection(con);
			
			return posts;
		} catch(Exception e) {
			return null;
		}
	}
}
