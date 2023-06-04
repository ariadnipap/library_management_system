-- MariaDB dump 10.19  Distrib 10.4.27-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: library_management_system
-- ------------------------------------------------------
-- Server version	10.4.27-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `administrator`
--

DROP TABLE IF EXISTS `administrator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `administrator` (
  `username` varchar(20) NOT NULL,
  PRIMARY KEY (`username`),
  CONSTRAINT `administrator_ibfk_1` FOREIGN KEY (`username`) REFERENCES `user` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book` (
  `book_id` int(11) NOT NULL AUTO_INCREMENT,
  `ISBN` varchar(50) NOT NULL,
  `title` varchar(100) NOT NULL,
  `school_name` varchar(75) DEFAULT NULL,
  `pages_number` int(11) NOT NULL,
  `publisher` varchar(50) DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `image` blob DEFAULT NULL,
  `library_operator_username` varchar(20) DEFAULT NULL,
  `language` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`book_id`),
  KEY `library_operator_username` (`library_operator_username`),
  KEY `book_ibfk_1` (`school_name`),
  CONSTRAINT `book_ibfk_1` FOREIGN KEY (`school_name`) REFERENCES `school` (`school_name`) ON DELETE CASCADE,
  CONSTRAINT `book_ibfk_2` FOREIGN KEY (`library_operator_username`) REFERENCES `library_operator` (`library_operator_username`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=236 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER autofill_school_name BEFORE INSERT ON book 
FOR EACH ROW BEGIN
    DECLARE operator_school_name VARCHAR(50);
    IF NEW.school_name IS NULL THEN
        SELECT school_name INTO operator_school_name
        FROM school_member
        WHERE school_member_username = (
            SELECT library_operator_username
            FROM library_operator
            WHERE library_operator_username = NEW.library_operator_username
        );
        SET NEW.school_name = operator_school_name;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `book_author`
--

DROP TABLE IF EXISTS `book_author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book_author` (
  `book_id` int(11) NOT NULL,
  `author_name` varchar(100) NOT NULL,
  PRIMARY KEY (`book_id`,`author_name`),
  CONSTRAINT `book_author_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `book_category`
--

DROP TABLE IF EXISTS `book_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book_category` (
  `book_id` int(11) NOT NULL,
  `category` varchar(50) NOT NULL,
  PRIMARY KEY (`book_id`,`category`),
  CONSTRAINT `book_category_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `book_keyword`
--

DROP TABLE IF EXISTS `book_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book_keyword` (
  `book_id` int(11) NOT NULL,
  `keyword` varchar(40) NOT NULL,
  PRIMARY KEY (`book_id`,`keyword`),
  CONSTRAINT `book_keyword_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `library_operator`
--

DROP TABLE IF EXISTS `library_operator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `library_operator` (
  `library_operator_username` varchar(20) NOT NULL,
  `administrator_username` varchar(20) NOT NULL DEFAULT 'admin',
  `approved` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`library_operator_username`),
  KEY `administrator_username` (`administrator_username`),
  CONSTRAINT `library_operator_ibfk_1` FOREIGN KEY (`library_operator_username`) REFERENCES `school_member` (`school_member_username`) ON DELETE CASCADE,
  CONSTRAINT `library_operator_ibfk_2` FOREIGN KEY (`administrator_username`) REFERENCES `administrator` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER library_operator_approval_trigger
BEFORE INSERT ON library_operator
FOR EACH ROW
BEGIN
    SET NEW.approved = 0;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER add_approved_library_operator_to_school
AFTER UPDATE ON library_operator
FOR EACH ROW
BEGIN
  IF (NEW.approved = 1 AND OLD.approved = 0) THEN
    UPDATE school
    INNER JOIN school_member ON school.school_name = school_member.school_name
    INNER JOIN user ON school_member.school_member_username = user.username
    SET school.library_operator_first_name = user.first_name,
        school.library_operator_last_name = user.last_name
    WHERE school_member.school_member_username = NEW.library_operator_username;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER library_operator_approved_trigger AFTER UPDATE ON library_operator
FOR EACH ROW
BEGIN
  DECLARE library_operator_school_name VARCHAR(100);
  DECLARE temp_reservation_id INT;
  DECLARE temp_username VARCHAR(100);
  DECLARE temp_book_id INT;
  DECLARE temp_res_date DATE;
  DECLARE temp_status VARCHAR(100);
  DECLARE temp_borrow_date DATE;
  DECLARE temp_returned_date DATE;
  DECLARE temp_due_date DATE;
  DECLARE last_reservation_id INT;

  IF NEW.approved = 1 AND OLD.approved <> NEW.approved THEN
    SELECT school_name INTO library_operator_school_name
    FROM school_member
    WHERE school_member_username = NEW.library_operator_username;

    UPDATE teacherstudent AS ts
    JOIN school_member AS sm ON ts.username = sm.school_member_username
    SET ts.library_operator_username = NEW.library_operator_username
    WHERE (ts.library_operator_username IS NULL OR ts.library_operator_username = '')
      AND sm.school_name = library_operator_school_name;

    UPDATE review AS rev
    JOIN school_member AS sm ON rev.user_username = sm.school_member_username
    SET rev.library_operator_username = NEW.library_operator_username
    WHERE (rev.library_operator_username IS NULL OR rev.library_operator_username = '')
      AND sm.school_name = library_operator_school_name;

    UPDATE book AS b
    SET b.library_operator_username = NEW.library_operator_username
    WHERE (b.library_operator_username IS NULL OR b.library_operator_username = '')
      AND b.school_name = library_operator_school_name;

    UPDATE reservation AS rese
    JOIN school_member AS sm ON rese.username = sm.school_member_username
    SET rese.library_operator_username = NEW.library_operator_username
    WHERE (rese.library_operator_username IS NULL OR rese.library_operator_username = '')
    AND sm.school_name = library_operator_school_name
    AND rese.status IN ('cancelled','pending');

    
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_reservations (
      reservation_id INT,
      username VARCHAR(100),
      book_id INT,
      reservation_date DATE,
      status VARCHAR(100)
    );

    
    INSERT INTO temp_reservations (reservation_id, username, book_id, reservation_date, status)
    SELECT res.reservation_id, res.username, res.book_id, res.reservation_date, res.status
    FROM reservation AS res
    JOIN school_member AS sm ON res.username = sm.school_member_username
    WHERE res.status IN ('loaned', 'skipped')
      AND (res.library_operator_username IS NULL OR res.library_operator_username = '')
      AND sm.school_name = library_operator_school_name;

    
    WHILE (SELECT COUNT(*) FROM temp_reservations) > 0 DO
      
      SELECT reservation_id, username, book_id, reservation_date, status
      INTO temp_reservation_id, temp_username, temp_book_id, temp_res_date, temp_status
      FROM temp_reservations
      LIMIT 1;

      
      DELETE FROM temp_reservations
      WHERE reservation_id = temp_reservation_id;

      
      SELECT borrow_date, returned_date, due_date
      INTO temp_borrow_date, temp_returned_date, temp_due_date
      FROM reserves
      WHERE reservation_id = temp_reservation_id;

      
      DELETE FROM reserves
      WHERE reservation_id = temp_reservation_id;

      DELETE FROM reservation
      WHERE reservation_id = temp_reservation_id;

      INSERT INTO reservation (username, book_id, reservation_date, library_operator_username, status)
      VALUES (temp_username, temp_book_id, temp_res_date, NEW.library_operator_username, temp_status);

      SELECT LAST_INSERT_ID() INTO last_reservation_id;

      INSERT INTO reserves (reservation_id, book_id, borrow_date, returned_date, due_date, username)
      VALUES (last_reservation_id, temp_book_id, temp_borrow_date, temp_returned_date, temp_due_date, temp_username);
    END WHILE;

    
    DROP TEMPORARY TABLE IF EXISTS temp_reservations;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reservation` (
  `reservation_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `book_id` int(11) NOT NULL,
  `reservation_date` date NOT NULL,
  `library_operator_username` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`reservation_id`),
  KEY `username` (`username`),
  KEY `book_id` (`book_id`),
  KEY `library_operator_username` (`library_operator_username`),
  CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`username`) REFERENCES `teacherstudent` (`username`) ON DELETE CASCADE,
  CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE CASCADE,
  CONSTRAINT `reservation_ibfk_3` FOREIGN KEY (`library_operator_username`) REFERENCES `library_operator` (`library_operator_username`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `set_reservation_status` BEFORE INSERT ON `reservation`
FOR EACH ROW BEGIN
    DECLARE teacherstudent_position VARCHAR(10);
    DECLARE book_title VARCHAR(200);
    DECLARE max_borrowed_count INT;
    DECLARE has_this_title_reserved INT;
    DECLARE num_reserved_books_pending INT;
    DECLARE has_this_title_borrowed INT;
    DECLARE num_of_due_books INT;

    IF NEW.status IS NULL OR (NEW.status <> 'loaned' AND NEW.status <> 'skipped') THEN

        SELECT position, num_of_books_allowed INTO teacherstudent_position, max_borrowed_count
        FROM teacherstudent
        WHERE username = NEW.username;


        SELECT COUNT(*) INTO num_reserved_books_pending
        FROM reservation
        WHERE username = NEW.username AND status = 'pending' AND reservation_date BETWEEN DATE_SUB(NOW(), INTERVAL 7 DAY) AND NOW();

        SELECT title INTO book_title
        FROM book
        WHERE book_id = NEW.book_id;

        SELECT COUNT(*) INTO has_this_title_reserved
        FROM reservation r
        JOIN book b ON r.book_id = b.book_id
        WHERE username = NEW.username AND b.title = book_title AND status = 'pending';

        IF has_this_title_reserved > 0 THEN
            SET NEW.status = 'rejected';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have already reserved this book.';
        END IF;
  
        SELECT COUNT(*) INTO has_this_title_borrowed
        FROM reserves r
        JOIN book b ON r.book_id = b.book_id
        WHERE username = NEW.username AND b.title = book_title AND returned_date IS NULL;

        IF has_this_title_borrowed > 0 THEN
            SET NEW.status = 'rejected';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You already have this book in your possession';
        END IF;

        SELECT COUNT(*) INTO num_of_due_books
        FROM reserves
        WHERE username = NEW.username AND returned_date IS NULL AND due_date < NOW();

        IF num_of_due_books > 0 THEN
            SET NEW.status = 'rejected';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have not returned a book on time.';
        END IF;

  
        IF num_reserved_books_pending >= max_borrowed_count THEN
            SET NEW.status = 'rejected';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have exceeded the maximum number of reserved/borrowed books.';
        END IF;

        SET NEW.status = 'pending';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `move_to_reserves` AFTER UPDATE ON `reservation`
FOR EACH ROW
BEGIN
  IF NEW.status = 'loaned' THEN
    INSERT INTO reserves (reservation_id, book_id, borrow_date, returned_date, due_date, username) 
    VALUES (NEW.reservation_id, NEW.book_id, CURRENT_DATE(), NULL, DATE_ADD(CURRENT_DATE(), INTERVAL 7 DAY), NEW.username);
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `reserves`
--

DROP TABLE IF EXISTS `reserves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reserves` (
  `reservation_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `borrow_date` date NOT NULL,
  `returned_date` date DEFAULT NULL,
  `due_date` date NOT NULL,
  `username` varchar(20) NOT NULL,
  PRIMARY KEY (`reservation_id`,`book_id`),
  KEY `book_id` (`book_id`),
  KEY `username_fk` (`username`),
  CONSTRAINT `reserves_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`) ON DELETE CASCADE,
  CONSTRAINT `reserves_ibfk_2` FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`reservation_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_3` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `review` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `text` text DEFAULT NULL,
  `likert_rating` int(11) NOT NULL CHECK (`likert_rating` >= 0 and `likert_rating` <= 5),
  `library_operator_username` varchar(20) DEFAULT NULL,
  `user_username` varchar(20) NOT NULL,
  `approved` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`review_id`),
  KEY `library_operator_username` (`library_operator_username`),
  KEY `review_ibfk_2` (`user_username`),
  CONSTRAINT `library_operator_username` FOREIGN KEY (`library_operator_username`) REFERENCES `library_operator` (`library_operator_username`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`user_username`) REFERENCES `user` (`username`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER review_teacher_approval_trigger
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE user_position VARCHAR(50);
    
    SELECT position INTO user_position
    FROM teacherstudent
    WHERE username = NEW.user_username;
    
    IF user_position = 'teacher' THEN
        SET NEW.approved = 1;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `school`
--

DROP TABLE IF EXISTS `school`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `school` (
  `school_name` varchar(75) NOT NULL,
  `city` varchar(70) NOT NULL,
  `email` varchar(50) NOT NULL,
  `school_director_first_name` varchar(20) NOT NULL,
  `school_director_last_name` varchar(50) NOT NULL,
  `library_operator_first_name` varchar(20) DEFAULT NULL,
  `library_operator_last_name` varchar(50) DEFAULT NULL,
  `street_number` varchar(5) DEFAULT NULL,
  `street_name` varchar(30) DEFAULT NULL,
  `zip_code` int(11) NOT NULL,
  `administrator_username` varchar(20) NOT NULL DEFAULT 'admin',
  `school_phone_number` varchar(20) NOT NULL,
  PRIMARY KEY (`school_name`),
  KEY `administrator_username` (`administrator_username`),
  CONSTRAINT `school_ibfk_1` FOREIGN KEY (`administrator_username`) REFERENCES `administrator` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `school_member`
--

DROP TABLE IF EXISTS `school_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `school_member` (
  `school_member_username` varchar(20) NOT NULL,
  `school_name` varchar(75) NOT NULL,
  PRIMARY KEY (`school_member_username`),
  KEY `school_member_ibfk_2` (`school_name`),
  CONSTRAINT `school_member_ibfk_1` FOREIGN KEY (`school_member_username`) REFERENCES `user` (`username`) ON DELETE CASCADE,
  CONSTRAINT `school_member_ibfk_2` FOREIGN KEY (`school_name`) REFERENCES `school` (`school_name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `teacherstudent`
--

DROP TABLE IF EXISTS `teacherstudent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teacherstudent` (
  `username` varchar(20) NOT NULL,
  `position` varchar(10) NOT NULL,
  `num_of_books_allowed` int(11) NOT NULL,
  `library_operator_username` varchar(20) DEFAULT NULL,
  `approved` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`username`),
  KEY `library_operator_username` (`library_operator_username`),
  CONSTRAINT `teacherstudent_ibfk_1` FOREIGN KEY (`username`) REFERENCES `school_member` (`school_member_username`) ON DELETE CASCADE,
  CONSTRAINT `teacherstudent_ibfk_2` FOREIGN KEY (`library_operator_username`) REFERENCES `library_operator` (`library_operator_username`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER set_num_of_books_allowed BEFORE INSERT ON teacherstudent
FOR EACH ROW
BEGIN
    IF NEW.position = 'teacher' THEN
        SET NEW.num_of_books_allowed = 1;
    ELSEIF NEW.position = 'student' THEN
        SET NEW.num_of_books_allowed = 2;
    END IF;  
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `username` varchar(20) NOT NULL,
  `password` varchar(50) NOT NULL,
  `first_name` varchar(25) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `date_of_birth` date NOT NULL,
  `email` varchar(50) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-06-04 22:13:57
