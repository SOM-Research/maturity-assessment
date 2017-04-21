CREATE DATABASE  IF NOT EXISTS `eclipse_projects_master_23032017` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `eclipse_projects_master_23032017`;
-- MySQL dump 10.13  Distrib 5.7.9, for Win64 (x86_64)
--
-- Host: som.uoc.es    Database: eclipse_projects_master_23032017
-- ------------------------------------------------------
-- Server version	5.6.25

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

--
-- Table structure for table `metrics_bus_factor`
--

DROP TABLE IF EXISTS `metrics_bus_factor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metrics_bus_factor` (
  `project_id` int(20) NOT NULL,
  `bus_factor` int(20) DEFAULT NULL,
  PRIMARY KEY (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metrics_bus_factor`
--

LOCK TABLES `metrics_bus_factor` WRITE;
/*!40000 ALTER TABLE `metrics_bus_factor` DISABLE KEYS */;
INSERT INTO `metrics_bus_factor` VALUES (1,1),(2,2),(3,1),(5,1),(6,3),(7,1),(8,1),(9,1),(10,3),(11,1),(12,1),(13,1),(14,1),(15,1),(16,1),(17,1),(19,1),(20,2),(21,1),(22,1),(23,1),(24,2),(25,1),(26,1),(28,2),(31,3),(32,3),(33,1),(35,2),(37,1),(38,2),(40,3),(41,2),(42,1),(43,1),(44,1),(45,1),(46,1),(47,1),(48,1),(49,1),(50,1),(51,2),(52,1),(53,2),(54,1),(56,2),(58,1),(60,1),(61,1),(62,2),(64,2),(69,1),(72,1),(73,1),(77,1),(78,1),(79,1),(81,1),(85,1),(86,2),(87,2),(88,2),(90,2),(91,2),(92,1),(93,2),(94,1),(95,2),(96,1),(97,1),(99,1),(100,1),(101,1),(102,1),(104,2),(105,2),(106,1),(107,1),(108,1),(109,1),(110,1),(112,2),(114,2),(117,1),(118,1),(119,2),(120,2),(122,3),(123,3),(127,1),(128,2),(129,1),(135,1),(142,1),(143,1),(145,2),(146,2),(147,1),(150,2),(153,2),(154,1),(155,1),(156,1),(157,3),(158,1),(159,1),(161,1),(163,1),(164,2),(165,1),(166,1),(170,1),(171,1),(172,2),(173,1),(175,2),(193,1),(195,1),(196,2),(197,2),(206,1),(208,1),(209,1),(210,1),(211,1),(213,2);
/*!40000 ALTER TABLE `metrics_bus_factor` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-04-21  9:35:15
