CREATE TABLE apis ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "session" varchar(255) DEFAULT NULL, "cookie" varchar(255) DEFAULT NULL, "user_id" integer DEFAULT NULL, "expired_at" datetime DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL);
CREATE TABLE branches ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "repository_id" integer DEFAULT NULL, "category_id" integer DEFAULT NULL, "name" varchar(255) DEFAULT NULL, "uri" varchar(255) DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL);
CREATE TABLE issues ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subject" varchar(255) DEFAULT NULL, "url" varchar(255) DEFAULT NULL, "reviewer_string" text DEFAULT NULL, "description" text DEFAULT NULL, "data" text DEFAULT NULL, "comment_count" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "closed" integer DEFAULT NULL, "base_id" integer DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL);
CREATE TABLE repositories ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255) DEFAULT NULL, "uri" varchar(255) DEFAULT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL);
CREATE TABLE reviewers ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "issue_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL);
CREATE TABLE schema_info (version integer);
CREATE TABLE users ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "login" varchar(255) DEFAULT NULL, "email" varchar(255) DEFAULT NULL, "crypted_password" varchar(40) DEFAULT NULL, "salt" varchar(40) DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL, "remember_token" varchar(255) DEFAULT NULL, "remember_token_expires_at" datetime DEFAULT NULL);
INSERT INTO schema_info (version) VALUES (6)