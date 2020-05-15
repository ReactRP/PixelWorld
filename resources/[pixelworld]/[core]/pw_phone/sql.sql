CREATE TABLE IF NOT EXISTS `phone_applications` (
  `charid` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `container` varchar(50) DEFAULT NULL,
  `icon` varchar(200) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `unread` int(2) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT 1,
  `uninstallable` tinyint(1) DEFAULT 0,
  `dumpable` tinyint(1) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS `phone_apps` (
  `charid` int(11) DEFAULT NULL,
  `app` varchar(50) DEFAULT NULL,
  `state` tinyint(1) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS `phone_calls` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sender` varchar(12) NOT NULL,
  `receiver` varchar(12) NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  `status` int(1) NOT NULL DEFAULT 0,
  `anon` int(1) NOT NULL DEFAULT 0,
  `sender_deleted` int(1) NOT NULL DEFAULT 0,
  `receiver_deleted` int(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `phone_contacts` (
  `charid` int(11) DEFAULT NULL,
  `number` varchar(12) DEFAULT NULL,
  `name` varchar(64) NOT NULL DEFAULT '-1',
  UNIQUE KEY `charid` (`charid`,`number`)
);

CREATE TABLE IF NOT EXISTS `phone_irc_channels` (
  `charid` int(10) DEFAULT 0,
  `joined` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `channel` varchar(50) NOT NULL,
  UNIQUE KEY `joined` (`joined`,`charid`),
  KEY `irc_charid` (`charid`),
  CONSTRAINT `irc_charid` FOREIGN KEY (`charid`) REFERENCES `characters` (`cid`) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS `phone_irc_messages` (
  `channel` varchar(50) DEFAULT NULL,
  `message` varchar(256) DEFAULT NULL,
  `date` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
);

CREATE TABLE IF NOT EXISTS `phone_settings` (
  `charid` int(11) DEFAULT NULL,
  `data` longtext DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS `phone_texts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sender` varchar(12) NOT NULL DEFAULT '0',
  `receiver` varchar(12) NOT NULL DEFAULT '0',
  `message` varchar(255) NOT NULL DEFAULT '0',
  `sent_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `sender_read` int(1) NOT NULL DEFAULT 1,
  `sender_deleted` int(1) NOT NULL DEFAULT 0,
  `receiver_read` int(1) NOT NULL DEFAULT 0,
  `receiver_deleted` int(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `sender` (`sender`),
  KEY `receiver` (`receiver`)
);

CREATE TABLE IF NOT EXISTS `phone_transfers` (
  `transfer_id` int(11) NOT NULL AUTO_INCREMENT,
  `from_account` int(11) NOT NULL DEFAULT 0,
  `to_account_number` int(8) NOT NULL DEFAULT 0,
  `to_sort_code` int(6) NOT NULL DEFAULT 0,
  `amount` int(11) NOT NULL DEFAULT 0,
  `request_date` int(11) NOT NULL DEFAULT 0,
  `process_date` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1,
  `receiptCID` int(11) NOT NULL DEFAULT 0,
  `senderCID` int(11) NOT NULL DEFAULT 0,
  `origin` varchar(50) DEFAULT NULL,
  `destination` varchar(50) DEFAULT NULL,
  `reason` longtext DEFAULT NULL,
  PRIMARY KEY (`transfer_id`)
);

CREATE TABLE IF NOT EXISTS `phone_tuner` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `charid` int(10) DEFAULT NULL,
  `data` varchar(256) NOT NULL DEFAULT '{}',
  KEY `id` (`id`),
  KEY `charid` (`charid`),
  CONSTRAINT `charid` FOREIGN KEY (`charid`) REFERENCES `characters` (`cid`) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS `phone_tweets` (
  `author_id` int(11) DEFAULT NULL,
  `author` varchar(50) NOT NULL,
  `message` varchar(255) NOT NULL,
  `time` datetime NOT NULL DEFAULT current_timestamp(),
  KEY `tweets_charid` (`author_id`),
  CONSTRAINT `tweets_charid` FOREIGN KEY (`author_id`) REFERENCES `characters` (`cid`) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS `phone_unread` (
  `charid` int(11) DEFAULT NULL,
  `data` longtext DEFAULT NULL
);
