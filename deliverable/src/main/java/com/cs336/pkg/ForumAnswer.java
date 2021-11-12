package com.cs336.pkg;

import java.util.Date;

public class ForumAnswer extends ForumReply {
	public ForumAnswer(int id, int postId, int creatorId, Date createdAt, String content) {
		super(id, postId, creatorId, createdAt, content);
	}
}

