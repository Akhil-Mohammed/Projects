package com.cs336.pkg;

import java.util.Date;

public class ForumReply {
	private int id, postId, creatorId;
	private Date createdAt;
	private String content;
	
	public ForumReply(int id, int postId, int creatorId, Date createdAt, String content) {
		this.id = id;
		this.postId = postId;
		this.creatorId = creatorId;
		this.createdAt = createdAt;
		this.content = content;
	}
	
	public int getId() {
		return id;
	}

	public int getPostId() {
		return postId;
	}

	public int getCreatorId() {
		return creatorId;
	}

	public Date getCreatedAt() {
		return createdAt;
	}

	public String getContent() {
		return content;
	}
}