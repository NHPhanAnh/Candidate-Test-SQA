-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: cvconnect-notify-service
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `cvconnect-notify-service`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cvconnect-notify-service` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `cvconnect-notify-service`;

--
-- Table structure for table `email_config`
--

DROP TABLE IF EXISTS `email_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `host` varchar(255) NOT NULL,
  `port` int NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `is_ssl` tinyint(1) DEFAULT '0',
  `protocol` varchar(50) DEFAULT 'smtp',
  `org_id` bigint DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `org_id` (`org_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_config`
--

LOCK TABLES `email_config` WRITE;
/*!40000 ALTER TABLE `email_config` DISABLE KEYS */;
INSERT INTO `email_config` VALUES (1,'smtp-relay.brevo.com',587,'a63959001@smtp-brevo.com','xsmtpsib-fd52b697ef5ffe7ce6ac4f7d62c4ae0a961e3466271d7ce17d01b9c7940b3cd7-2FrUlpCgCExHjia6',0,'smtp',NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL);
/*!40000 ALTER TABLE `email_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email_group` varchar(100) DEFAULT NULL,
  `sender` varchar(255) NOT NULL,
  `recipients` text NOT NULL,
  `cc_list` text,
  `subject` varchar(255) NOT NULL,
  `body` text,
  `candidate_info_id` bigint DEFAULT NULL,
  `job_ad_id` bigint DEFAULT NULL,
  `org_id` bigint DEFAULT NULL,
  `email_template_id` bigint DEFAULT NULL,
  `template` text,
  `template_variables` text,
  `status` varchar(100) NOT NULL,
  `error_message` text,
  `sent_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
INSERT INTO `email_logs` VALUES (1,'f5f58e5a-7e8f-47ef','nnmhqn2003@gmail.com','testx123@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=fda613ec-af79-4759-8962-76c098ee50b6\",\"username\":\"Test User\"}','FAILURE','535 5.7.8 Authentication failed\n',NULL,1,0,'2026-03-27 08:40:58','2026-03-27 12:28:01','ANONYMOUS','ANONYMOUS'),(2,'27b35485-1913-43f9','nnmhqn2003@gmail.com','debuguser03@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=254d44c6-8f2d-4f01-b3e3-97de7b7c9aa5\",\"username\":\"Debug User\"}','FAILURE','535 5.7.8 Authentication failed\n',NULL,1,0,'2026-03-27 12:26:52','2026-03-27 12:28:01','ANONYMOUS','ANONYMOUS'),(3,'259204ab-b4ab-41b1','nnmhqn2003@gmail.com','debuguser04@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=80fef129-4bee-4ce7-afc7-35e67d5fbfc5\",\"username\":\"Debug User\"}','FAILURE','535 5.7.8 Authentication failed\n',NULL,1,0,'2026-03-27 12:27:03','2026-03-27 12:35:53','ANONYMOUS','ANONYMOUS'),(4,'ffcb2c55-0dbd-438c','nnmhqn2003@gmail.com','nguyenhung.250904+ok@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=e55e7f2a-3b43-4846-92fd-90b23da4d076\",\"username\":\"nguyen manh hung\"}','FAILURE','535 5.7.8 Authentication failed\n',NULL,1,0,'2026-03-27 12:30:09','2026-03-27 12:35:53','ANONYMOUS','ANONYMOUS'),(5,'2d9a3b49-3c65-4853','nnmhqn2003@gmail.com','hungnguyen.250904@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=29edeb9a-0e7e-426e-9be2-0e7f22b6c5c8\",\"username\":\"nguyen manh hung\"}','FAILURE','535 5.7.8 Authentication failed\n',NULL,1,0,'2026-03-27 12:34:19','2026-03-27 12:35:53','ANONYMOUS','ANONYMOUS'),(6,'d8b87ffa-538c-4353','nnmhqn2003@gmail.com','nguyenhung.250904@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=da4970a1-6e16-421e-baaf-6dc31079c861\",\"username\":\"nguyen manh hung\"}','FAILURE','535 5.7.8 Authentication failed\n',NULL,1,0,'2026-03-27 12:53:07','2026-03-27 13:05:53','ANONYMOUS','ANONYMOUS'),(7,'c117e03f-3929-4822','nnmhqn2003@gmail.com','nguyenhung.250904@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=6da5eff9-eb36-4666-b431-2b79912995b5\",\"username\":\"nguyen manh hung\"}','FAILURE','535 5.7.8 Authentication failed\n',NULL,1,0,'2026-03-27 12:55:09','2026-03-27 13:05:53','ANONYMOUS','ANONYMOUS'),(8,'21a22ee7-6dc5-4077','nnmhqn2003@gmail.com','hungdz12345rr@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=f346e37e-a0ac-45bf-b197-73111e88cb29\",\"username\":\"nguyen manh hung\"}','SUCCESS',NULL,'2026-03-27 13:24:47',1,0,'2026-03-27 13:24:45','2026-03-27 13:24:47','ANONYMOUS','ANONYMOUS'),(9,'6645fca2-17a9-4ba9','nnmhqn2003@gmail.com','nguyenhung.250904@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=15291f98-b34b-4350-a017-2725fe924eef\",\"username\":\"nguyen manh hung\"}','SUCCESS',NULL,'2026-03-27 13:30:28',1,0,'2026-03-27 13:30:26','2026-03-27 13:30:28','ANONYMOUS','ANONYMOUS'),(10,'570ae889-27b7-4ee9','nnmhqn2003@gmail.com','nguyenhung25090406@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=19d2e062-4d95-4e4e-8085-bceebfcc12af\",\"username\":\"Hung\"}','SUCCESS',NULL,'2026-03-27 13:32:48',1,0,'2026-03-27 13:32:46','2026-03-27 13:32:48','ANONYMOUS','ANONYMOUS'),(11,'e8b4943a-fb9f-4ed7','nnmhqn2003@gmail.com','nguyenhung.250904@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=7d579c41-5a58-4a44-8a97-32666bcfda40\",\"username\":\"nguyen manh hung\"}','SUCCESS',NULL,'2026-03-27 13:43:53',1,0,'2026-03-27 13:43:51','2026-03-27 13:43:53','ANONYMOUS','ANONYMOUS'),(12,'27f51cdb-e840-488f','nguyenhung.250904@gmail.com','nguyenhung.250904@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=75fb2bd2-db7f-42d7-bedf-a2ce59d09f6f\",\"username\":\"nguyen manh hung\"}','SUCCESS',NULL,'2026-03-27 14:08:46',1,0,'2026-03-27 14:08:43','2026-03-27 14:08:46','ANONYMOUS','ANONYMOUS'),(13,'a2d9bbe6-1459-474d','nguyenhung.250904@gmail.com','nguyenduyphuong12112005@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=ca93c9fe-7ff5-46f2-8e00-ba40edb01d77\",\"username\":\"Nguyen duy phÆ°Æ¡ng \"}','SUCCESS',NULL,'2026-03-27 14:11:05',1,0,'2026-03-27 14:11:03','2026-03-27 14:11:05','ANONYMOUS','ANONYMOUS'),(14,'310fc740-00bf-4452','nguyenhung.250904@gmail.com','hungnguyen.250904@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=fb93556c-3483-4a17-8bc3-6c97c553a81c\",\"username\":\"nguyen manh hung\"}','SUCCESS',NULL,'2026-03-27 14:23:09',1,0,'2026-03-27 14:23:06','2026-03-27 14:23:09','ANONYMOUS','ANONYMOUS'),(15,'d4029784-cdbc-4015','nguyenhung.250904@gmail.com','manhung19112003@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=12fcdc34-b01d-48a0-91de-34cbb32ff90a\",\"username\":\"nguyen manh hung\"}','SUCCESS',NULL,'2026-03-27 15:13:10',1,0,'2026-03-27 15:13:08','2026-03-27 15:13:10','ANONYMOUS','ANONYMOUS'),(16,'83bad5c4-cd04-4ed3','nguyenhung.250904@gmail.com','ducvm2004@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=bcb8d0ad-fced-4fbb-98c7-649327fb61c7\",\"username\":\"nguyen minh duc \"}','SUCCESS',NULL,'2026-03-27 15:36:30',1,0,'2026-03-27 15:36:28','2026-03-27 15:36:30','ANONYMOUS','ANONYMOUS'),(17,'e48c4a55-5c25-4756','nguyenhung.250904@gmail.com','nguyenhung.250904055@gmail.com',NULL,'Verify your organization email',NULL,NULL,NULL,NULL,NULL,'VERIFY_ORG_EMAIL','{\"orgName\":\"BASEVN\",\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=122c9845-cb01-46ae-8b8a-5cc88af8b718\"}','SUCCESS',NULL,'2026-03-27 16:27:21',1,0,'2026-03-27 16:27:19','2026-03-27 16:27:21','ANONYMOUS','ANONYMOUS'),(18,'247530a7-24d8-4cdc','nguyenhung.250904@gmail.com','nguyenhung.250904@gmail.com',NULL,'Invitation to join organization',NULL,NULL,NULL,NULL,NULL,'INVITE_JOIN_ORG','{\"roleName\":\"Nhn vin tuyn dng\",\"fullName\":\"nguyen manh hung\",\"orgName\":\"BASEVN\",\"year\":\"2026\",\"acceptUrl\":\"http://localhost:3000/invite-join-org?token=82611d6f-454c-4df8-b57b-49624c1ae395&action=a\",\"rejectUrl\":\"http://localhost:3000/invite-join-org?token=82611d6f-454c-4df8-b57b-49624c1ae395&action=r\"}','SUCCESS',NULL,'2026-03-27 17:31:18',1,0,'2026-03-27 17:31:15','2026-03-27 17:31:18','ANONYMOUS','ANONYMOUS'),(19,'440725e7-9c68-41c7','nguyenhung.250904@gmail.com','hungdz12345rr@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=2be3efa0-850e-4e00-8339-05e32797de4a\",\"username\":\"nguyen manh hung\"}','SUCCESS',NULL,'2026-03-27 18:11:50',1,0,'2026-03-27 18:11:48','2026-03-27 18:11:50','ANONYMOUS','ANONYMOUS'),(20,'517c73f6-0489-4ce2','nnmhqn2003@gmail.com','autotest20260329164022@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=4552b94c-0602-4057-ad9a-6af4049c454f\",\"username\":\"Auto Test User\"}','SUCCESS',NULL,'2026-03-29 09:40:29',1,0,'2026-03-29 09:40:26','2026-03-29 09:40:29','ANONYMOUS','ANONYMOUS'),(21,'e641c379-b4ba-40f3','nnmhqn2003@gmail.com','autotest20260329164022@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=5999d6f4-10e2-49d7-8428-c5924c6dcf77\",\"username\":\"Auto Test User\"}','SUCCESS',NULL,'2026-03-29 09:41:22',1,0,'2026-03-29 09:41:20','2026-03-29 09:41:22','ANONYMOUS','ANONYMOUS'),(22,'0bd275fd-7d83-48b3','nnmhqn2003@gmail.com','diag164242@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=07050306-3a4f-4f7d-86af-2a8881075244\",\"username\":\"Diag User\"}','SUCCESS',NULL,'2026-03-29 09:42:45',1,0,'2026-03-29 09:42:43','2026-03-29 09:42:45','ANONYMOUS','ANONYMOUS'),(23,'52388399-8f52-4089','nnmhqn2003@gmail.com','afterfix164430@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=28ca5cfe-b9f6-4d06-bf47-3b80d6fc9e49\",\"username\":\"After Fix\"}','SUCCESS',NULL,'2026-03-29 09:44:33',1,0,'2026-03-29 09:44:31','2026-03-29 09:44:33','ANONYMOUS','ANONYMOUS'),(24,'fe1cb2f1-7eec-46a2','nnmhqn2003@gmail.com','smoke20260329164814@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=b82cf4b6-6196-4a35-bbd2-c5309fbae9f6\",\"username\":\"Smoke Test\"}','SUCCESS',NULL,'2026-03-29 09:48:20',1,0,'2026-03-29 09:48:17','2026-03-29 09:48:20','ANONYMOUS','ANONYMOUS'),(25,'fbcda96b-46a3-48b3','nnmhqn2003@gmail.com','smoke20260329164814@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=b885db8b-7a55-4620-a2eb-d312e3670d08\",\"username\":\"Smoke Test\"}','SUCCESS',NULL,'2026-03-29 09:48:20',1,0,'2026-03-29 09:48:18','2026-03-29 09:48:20','ANONYMOUS','ANONYMOUS'),(26,'b5a9f9b4-a226-443c','nnmhqn2003@gmail.com','fixcheck20260329193624447@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=0f84a5ca-f20b-4f11-aab2-2b2a92a52ff6\",\"username\":\"Fix Check\"}','SUCCESS',NULL,'2026-03-29 12:36:28',1,0,'2026-03-29 12:36:25','2026-03-29 12:36:28','ANONYMOUS','ANONYMOUS'),(27,'a9e30e50-1308-4d69','nnmhqn2003@gmail.com','iso_781549720@example.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=9cc26393-231e-46d2-add0-ed46078a9d75\",\"username\":\"Iso User\"}','SUCCESS',NULL,'2026-03-29 12:44:47',1,0,'2026-03-29 12:44:45','2026-03-29 12:44:47','ANONYMOUS','ANONYMOUS'),(28,'e0003fda-8c83-45c1','nguyenhung.250904@gmail.com','nguyenhung25090406@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=81654edc-1e56-41ac-9695-d45320e2b2fa\",\"username\":\"Hung\"}','SUCCESS',NULL,'2026-03-29 14:23:01',1,0,'2026-03-29 14:22:58','2026-03-29 14:23:01','ANONYMOUS','ANONYMOUS'),(29,'78a52dc1-9142-4b3f','nguyenhung.250904@gmail.com','hung2233250904@gmail.com',NULL,'Verify your email',NULL,NULL,NULL,NULL,NULL,'VERIFY_EMAIL','{\"year\":\"2026\",\"verifyUrl\":\"http://localhost:3000/account/verify-email?token=e3e3efcc-cfe1-4c4f-ab3f-23dc0768f296\",\"username\":\"Ung vien 1 \"}','SUCCESS',NULL,'2026-03-29 14:46:39',1,0,'2026-03-29 14:46:37','2026-03-29 14:46:39','ANONYMOUS','ANONYMOUS'),(30,'07610078-e135-4138','nguyenhung.250904055@gmail.com','hung2233250904@gmail.com',NULL,'ung vien ','<p>tuyen ok </p>',3,19,3,2,NULL,'{}','SUCCESS',NULL,'2026-03-29 18:43:54',1,0,'2026-03-29 18:43:52','2026-03-29 18:43:54','ANONYMOUS','ANONYMOUS'),(31,'cbaeb482-6cf2-44ab','nguyenhung.250904055@gmail.com','hung2233250904@gmail.com',NULL,'E2E check','ghi log test',3,19,3,NULL,NULL,'{}','SUCCESS',NULL,'2026-03-29 18:44:01',1,0,'2026-03-29 18:43:58','2026-03-29 18:44:01','ANONYMOUS','ANONYMOUS'),(32,'26e9227c-d9fa-4c60','nguyenhung.250904055@gmail.com','hung2233250904@gmail.com',NULL,'ung vien ','<p>tuyen ok </p>',3,19,3,2,NULL,'{}','SUCCESS',NULL,'2026-03-29 18:45:08',1,0,'2026-03-29 18:45:06','2026-03-29 18:45:08','ANONYMOUS','ANONYMOUS');
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_template_placeholder`
--

DROP TABLE IF EXISTS `email_template_placeholder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_template_placeholder` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email_template_id` bigint NOT NULL,
  `placeholder_id` bigint NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_template_id` (`email_template_id`,`placeholder_id`),
  KEY `placeholder_id` (`placeholder_id`),
  CONSTRAINT `email_template_placeholder_ibfk_1` FOREIGN KEY (`email_template_id`) REFERENCES `email_templates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `email_template_placeholder_ibfk_2` FOREIGN KEY (`placeholder_id`) REFERENCES `placeholders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_template_placeholder`
--

LOCK TABLES `email_template_placeholder` WRITE;
/*!40000 ALTER TABLE `email_template_placeholder` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_template_placeholder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_templates`
--

DROP TABLE IF EXISTS `email_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_templates` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  `name` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `org_id` bigint DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_org_idx` (`code`,`org_id`),
  KEY `code` (`code`,`org_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_templates`
--

LOCK TABLES `email_templates` WRITE;
/*!40000 ALTER TABLE `email_templates` DISABLE KEYS */;
INSERT INTO `email_templates` VALUES (1,'1122','Hung','nhap truong','<p>xin vao phong ban</p>',3,1,0,'2026-03-27 17:23:27',NULL,'HUngHR123',NULL),(2,'1212','hung','ung vien ','<p>tuyen ok </p>',3,1,0,'2026-03-29 17:49:52',NULL,'HUngHR123',NULL);
/*!40000 ALTER TABLE `email_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_config`
--

DROP TABLE IF EXISTS `job_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_name` varchar(100) NOT NULL,
  `schedule_type` varchar(50) NOT NULL,
  `expression` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_name` (`job_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_config`
--

LOCK TABLES `job_config` WRITE;
/*!40000 ALTER TABLE `job_config` DISABLE KEYS */;
INSERT INTO `job_config` VALUES (1,'email_resend','FIXED_RATE','900','Gi li email tht bi',1,0,'2026-03-27 07:54:02',NULL,'admin',NULL);
/*!40000 ALTER TABLE `job_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `placeholders`
--

DROP TABLE IF EXISTS `placeholders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `placeholders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  `label` varchar(255) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `member_type_used` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `label` (`label`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `placeholders`
--

LOCK TABLES `placeholders` WRITE;
/*!40000 ALTER TABLE `placeholders` DISABLE KEYS */;
INSERT INTO `placeholders` VALUES (1,'${jobPosition}','V tr tuyn dng',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(2,'${postTitle}','Tiu  tin ng',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(3,'${currentRound}','Tn vng hin ti',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(4,'${interviewLink}','ng dn phng vn trc tuyn',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(6,'${orgAddress}','a ch cng ty',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(7,'${candidateName}','Tn ng vin',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(8,'${salutation}','Anh/Ch',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(9,'${orgName}','Tn cng ty',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(10,'${hrName}','Tn HR',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(11,'${hrPhone}','ST HR',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(12,'${hrEmail}','Email HR',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(13,'${examDate}','Ngy lm bi thi/phng vn',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(14,'${startTime}','T gi',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(15,'${endTime}','n gi',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(16,'${examDuration}','Thi lng ca  thi',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(17,'${interview-examLocation}','a im phng vn/thi tuyn',NULL,NULL,1,0,'2026-03-27 07:54:02',NULL,'admin',NULL),(18,'${nextRound}','Tn vng tip theo',NULL,NULL,1,0,'2026-03-27 07:54:05',NULL,'admin',NULL);
/*!40000 ALTER TABLE `placeholders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shedlock`
--

DROP TABLE IF EXISTS `shedlock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shedlock` (
  `name` varchar(64) NOT NULL,
  `lock_until` datetime NOT NULL,
  `locked_at` datetime NOT NULL,
  `locked_by` varchar(255) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shedlock`
--

LOCK TABLES `shedlock` WRITE;
/*!40000 ALTER TABLE `shedlock` DISABLE KEYS */;
INSERT INTO `shedlock` VALUES ('email_resend','2026-04-01 11:52:26','2026-04-01 11:50:26','DESKTOP-8HTQB2G');
/*!40000 ALTER TABLE `shedlock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Current Database: `cvconnect-user-service`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cvconnect-user-service` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `cvconnect-user-service`;

--
-- Table structure for table `candidates`
--

DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidates` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `candidates_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidates`
--

LOCK TABLES `candidates` WRITE;
/*!40000 ALTER TABLE `candidates` DISABLE KEYS */;
INSERT INTO `candidates` VALUES (1,2,1,0,'2026-03-27 08:40:55',NULL,'ANONYMOUS',NULL),(2,3,1,0,'2026-03-27 12:26:52',NULL,'ANONYMOUS',NULL),(3,4,1,0,'2026-03-27 12:27:03',NULL,'ANONYMOUS',NULL),(4,5,1,0,'2026-03-27 12:30:09',NULL,'ANONYMOUS',NULL),(5,6,1,0,'2026-03-27 12:34:19',NULL,'ANONYMOUS',NULL),(6,7,1,0,'2026-03-27 12:53:07',NULL,'ANONYMOUS',NULL),(7,8,1,0,'2026-03-27 13:24:45',NULL,'ANONYMOUS',NULL),(8,9,1,0,'2026-03-27 13:32:46',NULL,'ANONYMOUS',NULL),(9,10,1,0,'2026-03-27 14:11:03',NULL,'ANONYMOUS',NULL),(10,11,1,0,'2026-03-27 15:13:07',NULL,'ANONYMOUS',NULL),(11,12,1,0,'2026-03-27 15:36:28',NULL,'ANONYMOUS',NULL),(12,13,1,0,'2026-03-27 16:27:19',NULL,'ANONYMOUS',NULL),(13,14,1,0,'2026-03-29 09:40:23',NULL,'ANONYMOUS',NULL),(14,15,1,0,'2026-03-29 09:42:43',NULL,'ANONYMOUS',NULL),(15,16,1,0,'2026-03-29 09:44:31',NULL,'ANONYMOUS',NULL),(16,17,1,0,'2026-03-29 09:48:17',NULL,'ANONYMOUS',NULL),(17,18,1,0,'2026-03-29 12:36:25',NULL,'ANONYMOUS',NULL),(18,19,1,0,'2026-03-29 12:44:44',NULL,'ANONYMOUS',NULL),(19,24,1,0,'2026-03-29 13:57:54',NULL,'ANONYMOUS',NULL),(20,25,1,0,'2026-03-29 14:46:36',NULL,'ANONYMOUS',NULL);
/*!40000 ALTER TABLE `candidates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_rollback`
--

DROP TABLE IF EXISTS `failed_rollback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_rollback` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` varchar(100) NOT NULL,
  `payload` text NOT NULL,
  `error_message` text,
  `status` tinyint(1) DEFAULT '0',
  `retry_count` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_rollback`
--

LOCK TABLES `failed_rollback` WRITE;
/*!40000 ALTER TABLE `failed_rollback` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_rollback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invite_join_org`
--

DROP TABLE IF EXISTS `invite_join_org`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invite_join_org` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `org_id` bigint NOT NULL,
  `token` varchar(255) NOT NULL,
  `status` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `role_id` (`role_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `invite_join_org_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `invite_join_org_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invite_join_org`
--

LOCK TABLES `invite_join_org` WRITE;
/*!40000 ALTER TABLE `invite_join_org` DISABLE KEYS */;
INSERT INTO `invite_join_org` VALUES (1,7,4,3,'82611d6f-454c-4df8-b57b-49624c1ae395','ACCEPTED',1,0,'2026-03-27 17:31:13','2026-03-27 17:34:55','HUngHR123','HUngHR123');
/*!40000 ALTER TABLE `invite_join_org` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_config`
--

DROP TABLE IF EXISTS `job_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_name` varchar(100) NOT NULL,
  `schedule_type` varchar(50) NOT NULL,
  `expression` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_name` (`job_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_config`
--

LOCK TABLES `job_config` WRITE;
/*!40000 ALTER TABLE `job_config` DISABLE KEYS */;
INSERT INTO `job_config` VALUES (1,'failed_rollback_retry','FIXED_RATE','600','Chy li Rollback data',1,0,'2026-03-27 07:55:38',NULL,'admin',NULL);
/*!40000 ALTER TABLE `job_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `management_members`
--

DROP TABLE IF EXISTS `management_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `management_members` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `management_members_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `management_members`
--

LOCK TABLES `management_members` WRITE;
/*!40000 ALTER TABLE `management_members` DISABLE KEYS */;
INSERT INTO `management_members` VALUES (1,1,1,0,'2026-03-27 07:55:34',NULL,'anonymous',NULL),(2,26,1,0,'2026-03-29 19:09:50',NULL,'seed-script',NULL);
/*!40000 ALTER TABLE `management_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menus` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  `label` varchar(255) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `parent_id` bigint DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '1',
  `for_member_type` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus`
--

LOCK TABLES `menus` WRITE;
/*!40000 ALTER TABLE `menus` DISABLE KEYS */;
INSERT INTO `menus` VALUES (1,'DASHBOARD','Dashboard','material-symbols:dashboard-2-outline','/system-admin/dashboard',NULL,10,'MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(2,'ORG','Doanh nghiep','material-symbols:person-play','/system-admin/organizations',NULL,20,'MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(3,'USER','Nguoi dung he thong','material-symbols:account-circle-full','/system-admin/users',NULL,30,'MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(4,'SETUP','Thiet lap','material-symbols:settings-b-roll-outline',NULL,NULL,40,NULL,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(5,'USER_GROUP','Nhm ngi dng','mdi:circle-medium','/system-admin/user-group',4,1,'MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(10,'PROCESS_TYPE','Vng tuyen dung','mdi:circle-medium','/system-admin/process-type',4,2,'MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(11,'CATEGORY','Danh muc','material-symbols:category-outline-rounded',NULL,NULL,50,NULL,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(12,'LEVEL','Cap bac','mdi:circle-medium','/system-admin/level',11,1,'MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(13,'INDUSTRY','Linh vuc','mdi:circle-medium','/system-admin/industry',11,2,'MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(14,'ORG_MEMBER','Thanh vien','material-symbols:account-circle-full','/org-admin/org-member',NULL,100,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(15,'ORG_ADDRESS','Dia Diem lam viec','mdi:circle-medium','/org-admin/org-address',4,1,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(17,'DEPARTMENT','Phong ban','mdi:circle-medium','/org-admin/department',11,1,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(18,'POSITION','Vi tri tuyen dung','mdi:circle-medium','/org-admin/position',11,2,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(19,'ORG_INFO','Thong tin chung','ri:info-card-line','/org-info',NULL,5,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(22,'ORG_CANDIDATE','Ung vin','material-symbols:person-pin-outline','/org/candidate',NULL,25,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(23,'ORG_JOB_AD','Tin tuyen dung','hugeicons:job-search','/org/job-ad',NULL,33,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(24,'ORG_ONBOARD','Danh sach onboard','material-symbols:person-check-outline-rounded','/org/onboard',NULL,37,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(25,'EMAIL_TEMPLATE','Mau Email','mdi:circle-medium','/org-admin/email-template',4,2,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(26,'ORG_CALENDAR','Lich','material-symbols:calendar-month-outline-rounded','/org/calendar',NULL,75,'ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(27,'CAREER','Nganh nghe','mdi:circle-medium','/system-admin/careers',11,3,'MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(28,'DASHBOARD_ORG','Dashboard','material-symbols:dashboard-2-outline','/org/dashboard',NULL,10,'ORGANIZATION',1,0,'2026-03-27 07:55:35',NULL,'admin',NULL);
/*!40000 ALTER TABLE `menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `org_members`
--

DROP TABLE IF EXISTS `org_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `org_members` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `org_id` bigint NOT NULL,
  `inviter` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `org_members_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `org_members`
--

LOCK TABLES `org_members` WRITE;
/*!40000 ALTER TABLE `org_members` DISABLE KEYS */;
INSERT INTO `org_members` VALUES (1,13,3,NULL,1,0,'2026-03-27 16:27:19',NULL,'ANONYMOUS',NULL),(2,7,3,'HUngHR123',1,0,'2026-03-27 17:34:55',NULL,'HUngHR123',NULL);
/*!40000 ALTER TABLE `org_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_menu`
--

DROP TABLE IF EXISTS `role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `menu_id` bigint NOT NULL,
  `permission` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_id` (`role_id`,`menu_id`),
  KEY `menu_id` (`menu_id`),
  CONSTRAINT `role_menu_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `role_menu_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `menus` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_menu`
--

LOCK TABLES `role_menu` WRITE;
/*!40000 ALTER TABLE `role_menu` DISABLE KEYS */;
INSERT INTO `role_menu` VALUES (1,1,1,NULL,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(2,1,2,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(3,1,3,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(4,1,4,NULL,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(5,1,5,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(10,1,10,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(11,1,11,NULL,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(12,1,12,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(13,1,13,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(15,3,14,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(16,3,15,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(18,3,17,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(19,3,18,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(20,3,4,NULL,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(21,3,11,NULL,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(22,3,28,'VIEW',1,0,'2026-03-27 17:18:25',NULL,'system-fix',NULL),(23,3,25,'VIEW,ADD,UPDATE,DELETE',1,0,'2026-03-27 17:18:25',NULL,'system-fix',NULL),(24,3,26,'VIEW',1,0,'2026-03-27 17:18:25',NULL,'system-fix',NULL),(25,3,22,'VIEW',1,0,'2026-03-27 17:18:25',NULL,'system-fix',NULL),(26,3,19,'VIEW,UPDATE',1,0,'2026-03-27 17:18:25',NULL,'system-fix',NULL),(27,3,23,'VIEW,ADD,UPDATE,DELETE,EXPORT',1,0,'2026-03-27 17:18:25','2026-03-27 17:28:24','system-fix','system-fix'),(28,3,24,'VIEW',1,0,'2026-03-27 17:18:25',NULL,'system-fix',NULL);
/*!40000 ALTER TABLE `role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_user`
--

DROP TABLE IF EXISTS `role_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_id` (`role_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `role_user_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `role_user_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_user`
--

LOCK TABLES `role_user` WRITE;
/*!40000 ALTER TABLE `role_user` DISABLE KEYS */;
INSERT INTO `role_user` VALUES (1,1,1,0,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(2,1,2,0,1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(3,2,2,0,1,0,'2026-03-27 08:40:55',NULL,'ANONYMOUS',NULL),(4,3,2,0,1,0,'2026-03-27 12:26:52',NULL,'ANONYMOUS',NULL),(5,4,2,0,1,0,'2026-03-27 12:27:03',NULL,'ANONYMOUS',NULL),(6,5,2,0,1,0,'2026-03-27 12:30:09',NULL,'ANONYMOUS',NULL),(7,6,2,0,1,0,'2026-03-27 12:34:19',NULL,'ANONYMOUS',NULL),(8,7,2,0,1,0,'2026-03-27 12:53:07',NULL,'ANONYMOUS',NULL),(9,8,2,0,1,0,'2026-03-27 13:24:45',NULL,'ANONYMOUS',NULL),(10,9,2,0,1,0,'2026-03-27 13:32:46',NULL,'ANONYMOUS',NULL),(11,10,2,0,1,0,'2026-03-27 14:11:03',NULL,'ANONYMOUS',NULL),(12,11,2,0,1,0,'2026-03-27 15:13:07',NULL,'ANONYMOUS',NULL),(13,12,2,0,1,0,'2026-03-27 15:36:28',NULL,'ANONYMOUS',NULL),(14,13,2,0,1,0,'2026-03-27 16:27:19',NULL,'ANONYMOUS',NULL),(15,13,3,0,1,0,'2026-03-27 16:27:19',NULL,'ANONYMOUS',NULL),(16,7,4,0,1,0,'2026-03-27 17:34:55',NULL,'HUngHR123',NULL),(17,14,2,0,1,0,'2026-03-29 09:40:23',NULL,'ANONYMOUS',NULL),(18,15,2,0,1,0,'2026-03-29 09:42:43',NULL,'ANONYMOUS',NULL),(19,16,2,0,1,0,'2026-03-29 09:44:31',NULL,'ANONYMOUS',NULL),(20,17,2,0,1,0,'2026-03-29 09:48:17',NULL,'ANONYMOUS',NULL),(21,18,2,0,1,0,'2026-03-29 12:36:25',NULL,'ANONYMOUS',NULL),(22,19,2,0,1,0,'2026-03-29 12:44:44',NULL,'ANONYMOUS',NULL),(23,24,2,0,1,0,'2026-03-29 13:57:54',NULL,'ANONYMOUS',NULL),(24,25,2,0,1,0,'2026-03-29 14:46:36',NULL,'ANONYMOUS',NULL),(25,26,1,1,1,0,'2026-03-29 19:09:50',NULL,'seed-script',NULL);
/*!40000 ALTER TABLE `role_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  `name` varchar(255) NOT NULL,
  `member_type` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'SYSTEM_ADMIN','Qun tr h thng','MANAGEMENT',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(2,'CANDIDATE','ng vin','CANDIDATE',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(3,'ORG_ADMIN','Qun tr t chc','ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(4,'HR','Nhn vin tuyn dng','ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL),(5,'INTERVIEWER','Ngi phng vn','ORGANIZATION',1,0,'2026-03-27 07:55:34',NULL,'admin',NULL);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shedlock`
--

DROP TABLE IF EXISTS `shedlock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shedlock` (
  `name` varchar(64) NOT NULL,
  `lock_until` datetime NOT NULL,
  `locked_at` datetime NOT NULL,
  `locked_by` varchar(255) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shedlock`
--

LOCK TABLES `shedlock` WRITE;
/*!40000 ALTER TABLE `shedlock` DISABLE KEYS */;
INSERT INTO `shedlock` VALUES ('failed_rollback_retry','2026-04-01 12:02:26','2026-04-01 12:00:26','DESKTOP-8HTQB2G');
/*!40000 ALTER TABLE `shedlock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `avatar_id` bigint DEFAULT NULL,
  `is_email_verified` tinyint(1) DEFAULT '0',
  `access_method` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2a$10$//aPySVETPhRYx/6xFKev.4S81w7Oq6zs44rnl9aeNe.u7W7GdFaq','nnmhqn2003@gmail.com','System Administrator','0123456789','123 Main St, City, Country',NULL,NULL,1,'LOCAL',1,0,'2026-03-27 07:55:34',NULL,'anonymous',NULL),(2,'testx123','$2a$10$a5nfcoFoM5rgWfMj7ycN6.BrN0kX07mJRNMnlGKQkOCYCt6rMHw7G','testx123@example.com','Test User',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-27 08:40:55',NULL,'ANONYMOUS',NULL),(3,'debuguser03','$2a$10$atPRAV2U7pXFkOmxfPdtEuh7FdrZy/YH5z42XuaZQiswYle0u6q62','debuguser03@example.com','Debug User',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-27 12:26:52',NULL,'ANONYMOUS',NULL),(4,'debuguser04','$2a$10$e9DlW25GP/pVN0b9.Ta66uOQFn571XIRstrI6fC1GmPcD2pbAKptW','debuguser04@example.com','Debug User',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-27 12:27:03',NULL,'ANONYMOUS',NULL),(5,'hung12345','$2a$10$8LXrIau5rzL2x.6NTW.Q/uU5Bf4DN5.FXCtPfRwmkk1NkuePq2dMK','nguyenhung.250904+ok@gmail.com','nguyen manh hung',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-27 12:30:09',NULL,'ANONYMOUS',NULL),(6,'nguyenmanhhung99','$2a$10$e8KRoeYy6H2vpG45E2dN5.IpLKljk4qVb63gcQ1vRSKvyHc.qPU.a','hungnguyen.250904@gmail.com','nguyen manh hung',NULL,NULL,NULL,NULL,1,'LOCAL',1,0,'2026-03-27 12:34:19','2026-03-27 14:23:32','ANONYMOUS','ANONYMOUS'),(7,'Hung@123','$2a$10$3Ao/WccAAZM.kTmHKn9iH.4OIto0FXMALaMjsZadKw5mi0wcU3r4a','nguyenhung.250904@gmail.com','nguyen manh hung',NULL,NULL,NULL,NULL,1,'LOCAL',1,0,'2026-03-27 12:53:07','2026-03-27 14:15:10','ANONYMOUS','ANONYMOUS'),(8,'Hung123456','$2a$10$JGTYT4eLr26Z9.4H0YfYa.VbtJBbyKWMkJLZcIRxALnbcCgRFAT1.','hungdz12345rr@gmail.com','nguyen manh hung',NULL,NULL,NULL,NULL,1,'LOCAL',1,0,'2026-03-27 13:24:45','2026-03-27 18:12:07','ANONYMOUS','ANONYMOUS'),(9,'Hhhhhhhh11','$2a$10$CwpxEsZkqPCzxwESXikr1ugLWdpiun7rehIEa2P26LH9za5vxiGGK','nguyenhung25090406@gmail.com','Hung',NULL,NULL,NULL,NULL,1,'LOCAL',1,0,'2026-03-27 13:32:46','2026-03-29 14:23:31','ANONYMOUS','ANONYMOUS'),(10,'Phonluong123','$2a$10$7v5nifGBUOZLt3n3v14WjeelHjhtvCCtwA0c89YbX/.FZkUoYGs4i','nguyenduyphuong12112005@gmail.com','Nguyen duy phÆ°Æ¡ng ',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-27 14:11:03',NULL,'ANONYMOUS',NULL),(11,'hungdb123','$2a$10$PpDS8kFoBItIoEozOqVipeyBl5xbL16tVVHOhQTu5WnAKWZZbDTc6','manhung19112003@gmail.com','nguyen manh hung',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-27 15:13:07',NULL,'ANONYMOUS',NULL),(12,'Ducnm@123','$2a$10$Z75SB0.azv/MTLAyeUFfE.2ZGNMUxGNojdAY9aieQ57tdEBK0k9iO','ducvm2004@gmail.com','nguyen minh duc ',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-27 15:36:28',NULL,'ANONYMOUS',NULL),(13,'HUngHR123','$2a$10$6TsXAmJVrBH17obx5UM91OdVEEnyyzXbkxSoqcJBMlYvglMwR2m.y','nguyenhung.250904055@gmail.com','nguyen manh hung',NULL,NULL,NULL,NULL,1,'LOCAL',1,0,'2026-03-27 16:27:15','2026-03-27 16:27:44','ANONYMOUS','ANONYMOUS'),(14,'autotest20260329164022','$2a$10$w/1wtMETIgb7kAvP7oNiFejre7pYHOmRQltAbRN7Ss1qEw44qehnS','autotest20260329164022@example.com','Auto Test User',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-29 09:40:23',NULL,'ANONYMOUS',NULL),(15,'diaguser164242','$2a$10$.jW9pVLKvEcjEoihLe0jbekw104wNuWj5tNbBjkhZ5IK5aWnr4/22','diag164242@example.com','Diag User',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-29 09:42:42',NULL,'ANONYMOUS',NULL),(16,'afterfix164430','$2a$10$c.OOkKLUmj0u.lKs1u/qkudMo/Bt.tHOFCCLK3WailDSLWAS1tXKy','afterfix164430@example.com','After Fix',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-29 09:44:31',NULL,'ANONYMOUS',NULL),(17,'smoke20260329164814','$2a$10$jjBjLAvmm9/B3ok4w7KpyOQQUPV4Zvul3k/5FS/9SMEUgj3Qq.S.6','smoke20260329164814@example.com','Smoke Test',NULL,NULL,NULL,NULL,1,'LOCAL',1,0,'2026-03-29 09:48:17',NULL,'ANONYMOUS',NULL),(18,'fixcheck20260329193624447','$2a$10$5VuX6lX2hr9GBvUWr2m8zOvaG5j6CzT.HRASn.F/d0IGzickYBJQy','fixcheck20260329193624447@example.com','Fix Check',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-29 12:36:25',NULL,'ANONYMOUS',NULL),(19,'iso1366005830','$2a$10$E6k6/bzURD/ri.TVGGMgSeTvmTFEk6C/C7H7Vlwgrzu06pMlAjf.y','iso_781549720@example.com','Iso User',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-29 12:44:44',NULL,'ANONYMOUS',NULL),(24,'Anh@1234','$2a$10$cbKYM900UzEpg7LWSEPVSuFfMVvwp5j6ofc.gu3t0HjDzDvL/I./O','vuapeslatao17@gmail.com','Nguyen hoang phan anh ',NULL,NULL,NULL,NULL,0,'LOCAL',1,0,'2026-03-29 13:57:53',NULL,'ANONYMOUS',NULL),(25,'Uvien@123','$2a$10$WuHIkqXz2v0YUpKUQ1jU8OK89FFJ.mjUplHnJjq4Vm9q4pDr75XIa','hung2233250904@gmail.com','Ung vien 1 ',NULL,NULL,NULL,NULL,1,'LOCAL',1,0,'2026-03-29 14:46:36','2026-03-29 14:46:56','ANONYMOUS','ANONYMOUS'),(26,'admin2','$2b$12$cYrMn2qIkTd8Ln.UYu7Lz.TjAvxc.33AgQtSRQ3c1ouxkBghxhtsa','admin2@cvconnect.local','System Admin 2','0123456788','Ha Noi',NULL,NULL,1,'LOCAL',1,0,'2026-03-29 19:09:50',NULL,'seed-script',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-10  1:56:43
