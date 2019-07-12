-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 11, 2019 at 09:59 PM
-- Server version: 5.7.26-0ubuntu0.16.04.1
-- PHP Version: 7.0.33-0ubuntu0.16.04.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dataCollection`
--
CREATE DATABASE IF NOT EXISTS `dataCollection` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `dataCollection`;

-- --------------------------------------------------------

--
-- Table structure for table `Event`
--

DROP TABLE IF EXISTS `Event`;
CREATE TABLE `Event` (
  `event` varchar(50) NOT NULL,
  `start` timestamp(3) NULL DEFAULT NULL,
  `end` timestamp(3) NULL DEFAULT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `KeyboardInput`
--

DROP TABLE IF EXISTS `KeyboardInput`;
CREATE TABLE `KeyboardInput` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(20) NOT NULL,
  `pid` varchar(10) NOT NULL,
  `start` varchar(10) NOT NULL,
  `xid` varchar(10) NOT NULL,
  `timeChanged` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `LastTransfer`
--

DROP TABLE IF EXISTS `LastTransfer`;
CREATE TABLE `LastTransfer` (
  `lastTransfer` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `MouseInput`
--

DROP TABLE IF EXISTS `MouseInput`;
CREATE TABLE `MouseInput` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(20) NOT NULL,
  `pid` varchar(10) NOT NULL,
  `start` varchar(10) NOT NULL,
  `xid` varchar(10) NOT NULL,
  `timeChanged` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `Process`
--

DROP TABLE IF EXISTS `Process`;
CREATE TABLE `Process` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(20) NOT NULL,
  `pid` varchar(10) NOT NULL,
  `start` varchar(10) NOT NULL,
  `command` text NOT NULL,
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `ProcessArgs`
--

DROP TABLE IF EXISTS `ProcessArgs`;
CREATE TABLE `ProcessArgs` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(20) NOT NULL,
  `pid` varchar(10) NOT NULL,
  `start` varchar(10) NOT NULL,
  `numbered` int(11) NOT NULL,
  `arg` text NOT NULL,
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `ProcessAttributes`
--

DROP TABLE IF EXISTS `ProcessAttributes`;
CREATE TABLE `ProcessAttributes` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(20) NOT NULL,
  `pid` varchar(10) NOT NULL,
  `start` varchar(10) NOT NULL,
  `cpu` decimal(10,0) NOT NULL,
  `mem` decimal(10,0) NOT NULL,
  `vsz` mediumint(9) NOT NULL,
  `rss` mediumint(9) NOT NULL,
  `tty` varchar(10) NOT NULL,
  `stat` varchar(10) NOT NULL,
  `time` varchar(10) NOT NULL,
  `timestamp` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `Screenshot`
--

DROP TABLE IF EXISTS `Screenshot`;
CREATE TABLE `Screenshot` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `taken` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `Task`
--

DROP TABLE IF EXISTS `Task`;
CREATE TABLE `Task` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `taskName` varchar(50) NOT NULL,
  `completion` double NOT NULL,
  `startTimestamp` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `TaskEvent`
--

DROP TABLE IF EXISTS `TaskEvent`;
CREATE TABLE `TaskEvent` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `taskName` varchar(50) NOT NULL,
  `eventTime` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
CREATE TABLE `User` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `UserIP`
--

DROP TABLE IF EXISTS `UserIP`;
CREATE TABLE `UserIP` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `ip` varchar(50) NOT NULL,
  `start` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `Window`
--

DROP TABLE IF EXISTS `Window`;
CREATE TABLE `Window` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(20) NOT NULL,
  `pid` varchar(10) NOT NULL,
  `start` varchar(10) NOT NULL,
  `xid` varchar(10) NOT NULL,
  `firstClass` varchar(20) NOT NULL,
  `secondClass` varchar(20) NOT NULL,
  `insertTimestamp` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `WindowDetails`
--

DROP TABLE IF EXISTS `WindowDetails`;
CREATE TABLE `WindowDetails` (
  `event` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session` varchar(50) NOT NULL,
  `user` varchar(20) NOT NULL,
  `pid` varchar(10) NOT NULL,
  `start` varchar(10) NOT NULL,
  `xid` varchar(10) NOT NULL,
  `x` int(11) NOT NULL,
  `y` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `name` text NOT NULL,
  `timeChanged` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Event`
--
ALTER TABLE `Event`
  ADD PRIMARY KEY (`event`);

--
-- Indexes for table `LastTransfer`
--
ALTER TABLE `LastTransfer`
  ADD PRIMARY KEY (`lastTransfer`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
