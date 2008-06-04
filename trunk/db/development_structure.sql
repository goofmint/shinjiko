CREATE TABLE `apis` (
  `id` int(11) NOT NULL auto_increment,
  `session` varchar(255) default NULL,
  `cookie` varchar(255) default NULL,
  `user_id` int(11) default NULL,
  `expired_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `branches` (
  `id` int(11) NOT NULL auto_increment,
  `repository_id` int(11) default NULL,
  `category_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `uri` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `issue_id` int(11) default NULL,
  `patchset_id` int(11) default NULL,
  `patch_id` int(11) default NULL,
  `line` int(11) default NULL,
  `draft` int(11) default NULL,
  `parent_id` int(11) default NULL,
  `patchset_left_id` int(11) default NULL,
  `patch_left_id` int(11) default NULL,
  `patchset_right_id` int(11) default NULL,
  `patch_right_id` int(11) default NULL,
  `side` varchar(255) default NULL,
  `snapshot` varchar(255) default NULL,
  `file` varchar(255) default NULL,
  `text` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `issues` (
  `id` int(11) NOT NULL auto_increment,
  `subject` varchar(255) default NULL,
  `reviewer_string` text,
  `description` text,
  `base` text,
  `user_id` int(11) default NULL,
  `closed` int(11) default NULL,
  `comment_count` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `members` (
  `id` int(11) NOT NULL auto_increment,
  `issue_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `issue_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `sendmail` int(11) default NULL,
  `subject` varchar(255) default NULL,
  `reviewer_string` varchar(255) default NULL,
  `message` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `patches` (
  `id` int(11) NOT NULL auto_increment,
  `patchset_id` int(11) default NULL,
  `parent_id` int(11) default NULL,
  `issue_id` int(11) default NULL,
  `comment_count` int(11) default NULL,
  `text` text,
  `content` text,
  `filename` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `patchsets` (
  `id` int(11) NOT NULL auto_increment,
  `issue_id` int(11) default NULL,
  `branch_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `parrent_id` int(11) default NULL,
  `comment_count` int(11) default NULL,
  `file` text,
  `message` text,
  `base` text,
  `url` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `repositories` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `uri` varchar(255) default NULL,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

INSERT INTO `schema_info` (version) VALUES (10)