-- MySQL dump 10.13  Distrib 5.7.30, for Linux (x86_64)
--
-- Host: localhost    Database: dataCollection
-- ------------------------------------------------------
-- Server version	5.7.30-0ubuntu0.18.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE IF NOT EXISTS `dataCollection` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `dataCollection`;

--
-- Table structure for table `Event`
--

DROP TABLE IF EXISTS `Event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Event` (
  `event` varchar(50) NOT NULL,
  `start` timestamp(3) NULL DEFAULT NULL,
  `end` timestamp(3) NULL DEFAULT NULL,
  `description` text NOT NULL,
  `continuous` text,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  PRIMARY KEY (`event`, `adminEmail`),
  KEY `Event_ibfk_1` (`adminEmail`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Process`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `User` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `sessionEnvironment` TEXT NOT NULL,
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`adminEmail`) USING BTREE,
  CONSTRAINT `User_ibfk_1` FOREIGN KEY (`event`, `adminEmail`) REFERENCES `Event` (`event`, `adminEmail`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `KeyboardInput`
--

DROP TABLE IF EXISTS `KeyboardInput`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `KeyboardInput` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(100) NOT NULL,
  `pid` varchar(100) NOT NULL,
  `start` varchar(100) NOT NULL,
  `xid` varchar(100) NOT NULL,
  `timeChanged` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `button` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL,
  `inputTime` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`user`,`pid`,`start`,`xid`,`timeChanged`,`inputTime`,`type`,`adminEmail`) USING BTREE,
  CONSTRAINT `KeyboardInput_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`, `xid`, `timeChanged`) REFERENCES `WindowDetails` (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`, `xid`, `timeChanged`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LastTransfer`
--

DROP TABLE IF EXISTS `LastTransfer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LastTransfer` (
  `lastTransfer` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`lastTransfer`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MouseInput`
--

DROP TABLE IF EXISTS `MouseInput`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MouseInput` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(100) NOT NULL,
  `pid` varchar(100) NOT NULL,
  `start` varchar(100) NOT NULL,
  `xid` varchar(100) NOT NULL,
  `timeChanged` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `type` varchar(100) NOT NULL,
  `xLoc` int(11) NOT NULL,
  `yLoc` int(11) NOT NULL,
  `inputTime` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`user`,`pid`,`start`,`xid`,`timeChanged`,`inputTime`,`adminEmail`) USING BTREE,
  CONSTRAINT `MouseInput_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`, `xid`, `timeChanged`) REFERENCES `WindowDetails` (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`, `xid`, `timeChanged`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Process`
--

DROP TABLE IF EXISTS `Process`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Process` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(100) NOT NULL,
  `pid` varchar(100) NOT NULL,
  `start` varchar(100) NOT NULL,
  `command` text NOT NULL,
  `parentpid` varchar(100) NOT NULL DEFAULT '0',
  `parentuser` varchar(100) NOT NULL DEFAULT '',
  `parentstart` varchar(100) NOT NULL DEFAULT '',
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`user`,`pid`,`start`,`adminEmail`) USING BTREE,
  CONSTRAINT `Process_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`) REFERENCES `User` (`event`, `adminEmail`, `username`, `session`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ProcessArgs`
--

DROP TABLE IF EXISTS `ProcessArgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ProcessArgs` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(100) NOT NULL,
  `pid` varchar(100) NOT NULL,
  `start` varchar(100) NOT NULL,
  `numbered` int(11) NOT NULL,
  `arg` text NOT NULL,
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`user`,`pid`,`start`,`numbered`,`adminEmail`) USING BTREE,
  CONSTRAINT `ProcessArgs_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`) REFERENCES `Process` (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ProcessAttributes`
--

DROP TABLE IF EXISTS `ProcessAttributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ProcessAttributes` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(100) NOT NULL,
  `pid` varchar(100) NOT NULL,
  `start` varchar(100) NOT NULL,
  `cpu` decimal(10,0) NOT NULL,
  `mem` decimal(10,0) NOT NULL,
  `vsz` bigint NOT NULL,
  `rss` bigint NOT NULL,
  `tty` varchar(100) NOT NULL,
  `stat` varchar(100) NOT NULL,
  `time` varchar(100) NOT NULL,
  `timestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`user`,`pid`,`start`,`timestamp`,`adminEmail`) USING BTREE,
  CONSTRAINT `ProcessAttributes_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`) REFERENCES `Process` (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Screenshot`
--

DROP TABLE IF EXISTS `Screenshot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Screenshot` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `taken` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `screenshot` longblob NOT NULL,
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`taken`,`adminEmail`) USING BTREE,
  CONSTRAINT `Screenshot_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`) REFERENCES `User` (`event`, `adminEmail`, `username`, `session`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Task`
--

DROP TABLE IF EXISTS `Task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Task` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `taskName` varchar(50) NOT NULL,
  `completion` double NOT NULL,
  `startTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`taskName`,`startTimestamp`,`adminEmail`) USING BTREE,
  CONSTRAINT `Task_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`) REFERENCES `User` (`event`, `adminEmail`, `username`, `session`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TaskEvent`
--

DROP TABLE IF EXISTS `TaskEvent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TaskEvent` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `taskName` varchar(50) NOT NULL,
  `eventTime` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `eventDescription` varchar(100) NOT NULL,
  `startTimestamp` timestamp(3) NOT NULL DEFAULT '1970-01-01 07:00:01.000',
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`taskName`,`eventTime`,`startTimestamp`,`adminEmail`) USING BTREE,
  KEY `event` (`event`, `adminEmail`,`username`,`session`,`taskName`,`startTimestamp`),
  CONSTRAINT `TaskEvent_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`, `taskName`, `startTimestamp`) REFERENCES `Task` (`event`, `adminEmail`, `username`, `session`, `taskName`, `startTimestamp`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `UploadToken`
--

DROP TABLE IF EXISTS `UploadToken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UploadToken` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `token` varchar(50) NOT NULL,
  `framesUploaded` int(11) NOT NULL DEFAULT '0',
  `framesRemaining` int(11) NOT NULL DEFAULT '0',
  `active` tinyint(4) NOT NULL DEFAULT '1',
  `lastAltered` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `continuous` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`event`, `username`,`token`,`adminEmail`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Window`
--

DROP TABLE IF EXISTS `Window`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Window` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(100) NOT NULL,
  `pid` varchar(100) NOT NULL,
  `start` varchar(100) NOT NULL,
  `xid` varchar(100) NOT NULL,
  `firstClass` TEXT NOT NULL,
  `secondClass` TEXT NOT NULL,
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`user`,`pid`,`start`,`xid`,`adminEmail`) USING BTREE,
  CONSTRAINT `Window_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`) REFERENCES `Process` (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `WindowDetails`
--

DROP TABLE IF EXISTS `WindowDetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `WindowDetails` (
  `event` varchar(50) NOT NULL,
  `adminEmail` varchar(100) NOT NULL DEFAULT 'cgtboy1988@yahoo.com',
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(100) NOT NULL,
  `pid` varchar(100) NOT NULL,
  `start` varchar(100) NOT NULL,
  `xid` varchar(100) NOT NULL,
  `x` int(11) NOT NULL,
  `y` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `name` text NOT NULL,
  `timeChanged` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  `active` INT NOT NULL DEFAULT '1',
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  PRIMARY KEY (`event`, `username`,`session`,`user`,`pid`,`start`,`xid`,`timeChanged`,`adminEmail`) USING BTREE,
  CONSTRAINT `WindowDetails_ibfk_1` FOREIGN KEY (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`, `xid`) REFERENCES `Window` (`event`, `adminEmail`, `username`, `session`, `user`, `pid`, `start`, `xid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `PerformanceMetrics`;
CREATE TABLE `PerformanceMetrics` ( `event` VARCHAR(50) NOT NULL ,
`adminEmail` VARCHAR(100) NOT NULL ,
`username` VARCHAR(50) NOT NULL ,
`session` VARCHAR(50) NOT NULL ,
`metricName` VARCHAR(50) NOT NULL ,
`metricValue1` DOUBLE NOT NULL ,
`metricUnit1` VARCHAR(50) NOT NULL ,
`metricValue2` DOUBLE NOT NULL DEFAULT '0' ,
`metricUnit2` VARCHAR(50) NULL DEFAULT NULL ,
`recordedTimestamp` TIMESTAMP(3) NOT NULL DEFAULT (utc_timestamp(3)),
`insertTimestamp` TIMESTAMP(3) NOT NULL DEFAULT (utc_timestamp(3)) ) ENGINE = InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `PerformanceMetrics` ADD PRIMARY KEY( `event`, `adminEmail`, `username`, `session`, `metricName`, `insertTimestamp`);

ALTER TABLE `PerformanceMetrics` ADD FOREIGN KEY (`event`, `adminEmail`, `username`, `session`) REFERENCES `User`(`event`, `adminEmail`, `username`, `session`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

