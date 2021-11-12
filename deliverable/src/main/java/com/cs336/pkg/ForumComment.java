package com.cs336.pkg;

import java.util.Date;

public class ForumComment extends ForumReply {
	public ForumComment(int id, int postId, int creatorId, Date createdAt, String content) {
		super(id, postId, creatorId, createdAt, content);
	}
}
