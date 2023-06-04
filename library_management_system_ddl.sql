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
  CONSTRAINT `book_ibfk_1` FOREIGN KEY (`school_name`) REFERENCES `school` (`school_name`) ON DELETE CASCADE ON UPDATE CASCADE,
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

CREATE TRIGGER autofill_school_name BEFORE INSERT ON book 
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
END;;

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

CREATE TRIGGER add_approved_library_operator_to_school
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
END;;

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
CREATE TRIGGER library_operator_approved_trigger AFTER UPDATE ON library_operator
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
END;;

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
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
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
CREATE TRIGGER `set_reservation_status` BEFORE INSERT ON `reservation`
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
END;;

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

CREATE TRIGGER `move_to_reserves` AFTER UPDATE ON `reservation`
FOR EACH ROW
BEGIN
  IF NEW.status = 'loaned' THEN
    INSERT INTO reserves (reservation_id, book_id, borrow_date, returned_date, due_date, username) 
    VALUES (NEW.reservation_id, NEW.book_id, CURRENT_DATE(), NULL, DATE_ADD(CURRENT_DATE(), INTERVAL 7 DAY), NEW.username);
  END IF;
END;;

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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
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

CREATE TRIGGER review_teacher_approval_trigger
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
END;;

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
  CONSTRAINT `school_member_ibfk_2` FOREIGN KEY (`school_name`) REFERENCES `school` (`school_name`) ON DELETE CASCADE ON UPDATE CASCADE
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

CREATE TRIGGER set_num_of_books_allowed BEFORE INSERT ON teacherstudent
FOR EACH ROW
BEGIN
    IF NEW.position = 'teacher' THEN
        SET NEW.num_of_books_allowed = 1;
    ELSEIF NEW.position = 'student' THEN
        SET NEW.num_of_books_allowed = 2;
    END IF;  
END;;

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

--
-- Dumping events for database 'library_management_system'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `cancel_expired_reservations` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
CREATE EVENT `cancel_expired_reservations` ON SCHEDULE EVERY 1 DAY STARTS '2023-06-03 13:20:46' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
  UPDATE reservation
  SET status = 'cancelled'
  WHERE reservation_date <= CURRENT_DATE - INTERVAL 7 DAY
    AND status = 'pending';
END;;

/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'library_management_system'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `accept_reservation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `accept_reservation`(
    IN operator_username VARCHAR(50),
    IN user_username VARCHAR(50),
    IN p_reservation_id INT,
    IN my_book_id INT
)
BEGIN
    DECLARE operator_approved INT;
    DECLARE user_approved INT;
    DECLARE book_loaned INT;
    DECLARE num_books_allowed INT;
    DECLARE current_week_loan_count INT;
    DECLARE has_delayed_return INT;
    
    
    SELECT COUNT(*) INTO operator_approved
    FROM library_operator
    WHERE library_operator_username = operator_username AND approved = 1;

    SELECT COUNT(*) INTO user_approved
    FROM teacherstudent
    WHERE username = user_username AND approved = 1;
    
    IF operator_approved > 0 THEN

        IF user_approved > 0 THEN 

            SELECT COUNT(*) INTO book_loaned
            FROM reserves r 
            WHERE r.book_id = my_book_id
            AND r.returned_date IS NULL;

            IF book_loaned = 0 THEN
        
                SELECT t.num_of_books_allowed INTO num_books_allowed
                FROM teacherstudent t
                WHERE t.username = user_username;
        
                SELECT COUNT(*) INTO current_week_loan_count
                FROM reserves r
                WHERE r.username = user_username
                AND r.borrow_date > DATE_SUB(CURDATE(), INTERVAL 1 WEEK);

                IF (current_week_loan_count < num_books_allowed) THEN

                    SELECT COUNT(*) INTO has_delayed_return
                    FROM reserves
                    WHERE username = user_username 
                    AND returned_date IS NULL 
                    AND due_date < CURDATE();
        
                    IF (has_delayed_return = 0) THEN
                            
                        UPDATE reservation
                        SET status = 'loaned'
                        WHERE reservation_id = p_reservation_id;
                        
                        SELECT 'Loan recorded successfully.' AS message;

                    ELSE
                        SELECT 'Loan criteria not met: User has not returned a book on time' AS message;
                    END IF;
                    
                ELSE
                    SELECT 'Loan criteria not met: User has exceeded the limit of loans this week' AS message;
                END IF;

            ELSE
                SELECT 'Book is currently loaned by another user' AS message;
            END IF;
            
        ELSE 
            SELECT 'School member does not exist or is not approved.' AS message;
        END IF;
        
    ELSE
        SELECT 'Unauthorized library operator.' AS message;
    END IF;
       
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_book`(
    IN isbn VARCHAR(50),
    IN title VARCHAR(100),
    IN pages_number INT,
    IN publisher VARCHAR(50),
    IN summary TEXT,
    IN copies INT,
    IN image BLOB,
    IN operator_username VARCHAR(50),
    IN language VARCHAR(20),
    IN authors VARCHAR(255),
    IN categories VARCHAR(255),
    IN keywords VARCHAR(255)
)
BEGIN
    DECLARE operator_count INT;
    DECLARE operator_school_name VARCHAR(100);
    DECLARE copy_counter INT;
    
    SELECT COUNT(*) INTO operator_count
    FROM library_operator
    WHERE library_operator_username = operator_username
      AND approved = 1;
    
    IF operator_count > 0 THEN
        
        SELECT school_name INTO operator_school_name
        FROM school_member
        WHERE school_member_username = operator_username;
        
        SET copy_counter = copies;
        
        WHILE copy_counter > 0 DO
        
            INSERT INTO book (isbn, title, school_name, pages_number, publisher, summary, image, library_operator_username, language) 
            VALUES (isbn, title, operator_school_name, pages_number, publisher, summary, image, operator_username, language);
        
            SET @last_book_id = LAST_INSERT_ID();
        
            IF authors IS NOT NULL THEN
                SET @author_string = authors;
                WHILE @author_string <> '' DO
                    SET @author = SUBSTRING_INDEX(@author_string, ',', 1);
                    SET @author_string = SUBSTRING(@author_string, LENGTH(@author) + 2);
                    
                    INSERT INTO book_author (book_id, author_name)
                    VALUES (@last_book_id, TRIM(@author));
                END WHILE;
            END IF;
        
            IF categories IS NOT NULL THEN
                SET @category_string = categories;
                WHILE @category_string <> '' DO
                    SET @category = SUBSTRING_INDEX(@category_string, ',', 1);
                    SET @category_string = SUBSTRING(@category_string, LENGTH(@category) + 2);
                    
                    INSERT INTO book_category (book_id, category)
                    VALUES (@last_book_id, TRIM(@category));
                END WHILE;
            END IF;
        
            IF keywords IS NOT NULL THEN
                SET @keyword_string = keywords;
                WHILE @keyword_string <> '' DO
                    SET @keyword = SUBSTRING_INDEX(@keyword_string, ',', 1);
                    SET @keyword_string = SUBSTRING(@keyword_string, LENGTH(@keyword) + 2);
                    
                    INSERT INTO book_keyword (book_id, keyword)
                    VALUES (@last_book_id, TRIM(@keyword));
                END WHILE;
            END IF;

            SET copy_counter = copy_counter - 1;
        
        END WHILE;
    
    END IF;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_review` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_review`(
    IN p_title VARCHAR(100),
    IN p_text TEXT,
    IN p_likert_rating INT,
    IN p_user_username VARCHAR(50)
)
BEGIN
    DECLARE is_approved INT;
    DECLARE operator_username VARCHAR(50);
    DECLARE is_student INT;
    DECLARE book_title_exists INT;

    
    SELECT COUNT(*) INTO is_approved
    FROM teacherstudent
    WHERE username = p_user_username AND approved = 1;
    
    
    IF is_approved > 0 THEN

        SELECT COUNT(*) INTO book_title_exists
        FROM Book
        WHERE title = p_title;

        IF book_title_exists > 0 THEN

            SELECT COUNT(*) INTO is_student
            FROM teacherstudent
            WHERE username = p_user_username AND position = 'student';

            SELECT lo.library_operator_username INTO operator_username
            FROM library_operator lo
            JOIN school_member sm_lo ON lo.library_operator_username = sm_lo.school_member_username
            JOIN school_member sm_ts ON sm_lo.school_name = sm_ts.school_name
            JOIN teacherstudent ts ON sm_ts.school_member_username = ts.username
            WHERE ts.username = p_user_username;
        
            INSERT INTO review (title, text, likert_rating, library_operator_username, user_username)
            VALUES (p_title, p_text, p_likert_rating, operator_username, p_user_username);
        
            IF is_student = 0 THEN
                SELECT 'Review added successfully.' AS message;
            ELSE 
                SELECT 'Review approval pending.' AS message;
            END IF;
        ELSE
            SELECT 'This book title does not exist in the database.' AS message;
        END IF;
    ELSE
        SELECT 'You are not approved to write reviews.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `approve_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `approve_library_operator`(
    IN ses_username VARCHAR(20),
    IN operator_username VARCHAR(20)
)
BEGIN
    DECLARE is_admin INT;
    DECLARE operator_exists INT;
    DECLARE operator_school VARCHAR(100);
    
    SELECT sm.school_name INTO operator_school
    FROM school_member sm
    WHERE sm.school_member_username = operator_username;

    SELECT COUNT(*) INTO is_admin 
    FROM administrator 
    WHERE username = ses_username;

    SELECT COUNT(*) INTO operator_exists
    FROM library_operator l 
    INNER JOIN school_member sm ON sm.school_member_username = l.library_operator_username
    WHERE l.approved = 1
    AND sm.school_name = operator_school;

    IF is_admin > 0 THEN 

        IF operator_exists = 0 THEN
            UPDATE library_operator
            SET approved = 1 
            WHERE library_operator_username = operator_username;

            SELECT 'Library operator updated successfully!' AS message;
        
        ELSE 
            SELECT 'There is already an approved library operator in this school!' AS message;
        END IF;

    ELSE
        SELECT 'You are not authorized to approve an operator.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `approve_review` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `approve_review`(    IN library_operator_username_param VARCHAR(50),    IN user_username_param VARCHAR(50),     IN title_param VARCHAR(100),    IN review_id_param INT)
BEGIN     DECLARE operator_approved INT;    DECLARE user_approved INT;    DECLARE library_operator_school VARCHAR(100);    DECLARE same_school_oper_user INT;    DECLARE same_school_book INT;    SELECT COUNT(*) INTO operator_approved    FROM library_operator    WHERE library_operator_username =library_operator_username_param    AND approved = 1;    IF operator_approved > 0 THEN        SELECT school_name INTO library_operator_school        FROM school_member         WHERE school_member_username = library_operator_username_param;        SELECT COUNT(*) INTO user_approved         FROM teacherstudent        WHERE username = user_username_param AND approved = 1;        IF user_approved > 0 THEN             SELECT COUNT(*) INTO same_school_oper_user            FROM school_member             WHERE school_member_username = user_username_param             AND school_name = library_operator_school;            IF same_school_oper_user > 0 THEN                 SELECT COUNT(*) INTO same_school_book                FROM book                WHERE title = title_param                 AND school_name = library_operator_school;                IF same_school_book > 0 THEN                    UPDATE review                    SET approved = 1                    WHERE review_id = review_id_param;                    IF ROW_COUNT() > 0 THEN                        SELECT 'Review approved successfully.' AS message;                    ELSE                        SELECT 'Something went wrong with the approval.' AS message;                    END IF;                ELSE                    SELECT 'This review does not concern a book that belongs to your school.'  AS message;                END IF;            ELSE                 SELECT 'You do not belong to the same school as the user whose review you want to approve.' AS message;            END IF;        ELSE             SELECT 'Teacher/student does not exist or is not approved.' AS message;        END IF;    ELSE        SELECT 'You are not an approved library operator.' AS message;        END IF;END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `approve_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `approve_user`(    IN user_username VARCHAR(20),    IN operator_username VARCHAR(20))
BEGIN    
DECLARE operator_approved INT;    

SELECT COUNT(*) INTO operator_approved   
FROM library_operator    
WHERE library_operator_username = operator_username AND approved = 1;   

IF operator_approved > 0 THEN        
UPDATE teacherstudent        
SET approved = 1        
WHERE username = user_username;        
SELECT 'User approved successfully.' AS message;    

ELSE        
 SELECT 'You are not an approved library operator.' AS message;    END IF;END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `average_user_rating_per_category` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `average_user_rating_per_category`(
    IN library_operator_username_param VARCHAR(50),
    IN username_param VARCHAR(50),
    IN category_param VARCHAR(50)
)
BEGIN 
    SELECT r.user_username, c.category, AVG(r.likert_rating)
    FROM review r
    JOIN book b ON r.title= b.title
    JOIN book_category c ON b.book_id = c.book_id
    WHERE r.approved = 1 AND b.school_name = (SELECT school_name FROM school_member WHERE school_member_username = library_operator_username_param)
    AND r.user_username = username_param
    AND c.category = category_param;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cancel_reservation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_reservation`(
    IN p_reservation_id INT,
    IN p_teacherstudent_username VARCHAR(50)
)
BEGIN
    
    UPDATE reservation
    SET status = 'cancelled'
    WHERE reservation_id = p_reservation_id
      AND username = p_teacherstudent_username
      AND status = 'pending';
      
    IF ROW_COUNT() > 0 THEN
        SELECT 'Reservation cancelled successfully.' AS message;
    ELSE
        SELECT 'Cannot cancel reservation. Invalid reservation ID or status.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `category_average_rating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `category_average_rating`(
    IN library_operator_username_param VARCHAR(50),
    IN category_param VARCHAR(50)
)
BEGIN 
    SELECT c.category, AVG(r.likert_rating)
    FROM review r
    JOIN book b ON r.title = b.title
    JOIN book_category c ON b.book_id= c.book_id
    WHERE r.approved =1 AND b.school_name = (SELECT school_name FROM school_member WHERE school_member_username = library_operator_username_param)
    AND ((category_param IS NULL OR category_param = '') OR c.category = category_param)
    GROUP BY c.category ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `change_user_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `change_user_password`(
    IN p_username VARCHAR(50),
    IN p_current_password VARCHAR(50),
    IN p_new_password VARCHAR(50)
)
BEGIN
    DECLARE user_exists INT;
    DECLARE current_password_match INT;
    
    
    SELECT COUNT(*) INTO user_exists
    FROM user
    WHERE username = p_username;
    
    
    IF user_exists > 0 THEN
        SELECT COUNT(*) INTO current_password_match
        FROM user
        WHERE username = p_username AND password = p_current_password;
        
        
        IF current_password_match > 0 THEN
            UPDATE user
            SET password = p_new_password
            WHERE username = p_username;
            
            SELECT 'Password changed successfully.' AS message;
        ELSE
            SELECT 'Current password is incorrect.' AS message;
        END IF;
    ELSE
        SELECT 'User not found.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_username` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `check_username`(IN my_username VARCHAR(20))
BEGIN
    DECLARE user_exists INT;

    SELECT COUNT(*) INTO user_exists
    FROM user
    WHERE username = my_username;

    SELECT user_exists;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_database_backup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_book`(
    IN my_book_id INT
)
BEGIN
    DECLARE book_reserved INT;
    DECLARE book_loaned INT;

    SELECT COUNT(*) INTO book_reserved
    FROM reservation
    WHERE book_id = my_book_id AND status='pending';

    SELECT COUNT(*) INTO book_loaned
    FROM reserves
    WHERE book_id = my_book_id AND returned_date IS NULL;

    IF book_reserved = 0 AND book_loaned = 0 THEN
        DELETE FROM book 
        WHERE book_id = my_book_id;

        SELECT 'Book deleted successfully.' AS message;
    ELSE 
        SELECT 'This book is either reserved or loaned!' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_library_operator`(
    IN operator_username VARCHAR(50)
)
BEGIN
    DELETE FROM library_operator
    WHERE library_operator_username = operator_username;

    DELETE FROM school_member
    WHERE school_member_username = operator_username;

    DELETE FROM user
    WHERE username = operator_username;

    UPDATE school
    SET library_operator_first_name = NULL, 
        library_operator_last_name = NULL
    WHERE school_name = (
        SELECT school_name
        FROM school_member
        WHERE school_member_username = operator_username
    );

    SELECT 'School member deleted successfully.' AS Message;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_my_review` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_my_review`(
    IN username_param VARCHAR(50),
    IN review_id_param INT
)
BEGIN
    
    DELETE FROM review
    WHERE review_id = review_id_param AND user_username = username_param;
      
    IF ROW_COUNT() > 0 THEN
        SELECT 'Review deleted successfully.' AS message;
    ELSE
        SELECT 'Cannot delete review. Invalid review ID.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_review` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_review`(
    IN username_param VARCHAR(50),
    IN review_id_param INT
)
BEGIN
    DECLARE user_approved INT ;

    SELECT COUNT(*) INTO user_approved
    FROM library_operator
    WHERE library_operator_username = username_param AND approved = 1;

    IF user_approved >0 THEN 
    DELETE FROM review
    WHERE review_id = review_id_param ;
      
    IF ROW_COUNT() > 0 THEN
        SELECT 'Review deleted successfully.' AS message;
    ELSE
        SELECT 'Cannot delete review. Invalid review ID.' AS message;
    END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_teacher_student` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_teacher_student`(
    IN operator_username VARCHAR(50),
    IN teacherstudent_username VARCHAR(50)
)
BEGIN
DECLARE operator_approved INT;
DECLARE operator_school_name VARCHAR(50);
DECLARE student_school_name VARCHAR(50);
DECLARE user_has_loan INT;
    
    SELECT COUNT(*) INTO operator_approved 
    FROM library_operator 
    WHERE library_operator_username = operator_username AND approved = 1;
    
    IF operator_approved > 0 THEN
        
        SELECT school_name INTO operator_school_name 
        FROM school_member 
        WHERE school_member_username = operator_username;
        
        SELECT school_name INTO student_school_name 
        FROM school_member 
        WHERE school_member_username = teacherstudent_username;
        
        IF operator_school_name = student_school_name THEN

            SELECT COUNT(*) INTO user_has_loan
            FROM reserves
            WHERE username = teacherstudent_username AND returned_date IS NULL;

                IF user_has_loan = 0 THEN
            
                    DELETE FROM teacherstudent 
                    WHERE username = teacherstudent_username;

                    DELETE FROM school_member
                    WHERE school_member_username = teacherstudent_username;

                    DELETE FROM user
                    WHERE username = teacherstudent_username;

                    SELECT 'School member deleted successfully.' AS Message;
                ELSE 
                    SELECT 'User has not yet returned a book!' AS message;
                END IF;
        ELSE
            SELECT 'Operator and member belong to different schools.' AS Message;
        END IF;
    ELSE
        SELECT 'Operator not approved.' AS Message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `disable_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `disable_library_operator`(
    IN ses_username VARCHAR(50),
    IN operator_username VARCHAR(50)
)
BEGIN
    DECLARE is_admin INT;
    
    SELECT COUNT(*) INTO is_admin
    FROM administrator
    WHERE username = ses_username;
    
    IF is_admin > 0 THEN

        UPDATE school
        SET library_operator_first_name = NULL, 
        library_operator_last_name = NULL
        WHERE school_name = (
            SELECT school_name
            FROM school_member
            WHERE school_member_username = operator_username
        );

        UPDATE library_operator
        SET approved = 0
        WHERE library_operator_username = operator_username;
            
        SELECT 'Library operator disabled successfully.' AS message;
    ELSE
        SELECT 'You are not authorized to disable operators.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `disable_teacherstudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `disable_teacherstudent`(
    IN operator_username VARCHAR(50),
    IN teacherstudent_username VARCHAR(50)
)
BEGIN
    DECLARE library_operator_school VARCHAR(50);
    DECLARE library_operator_approved INT;
    DECLARE teacherstudent_school VARCHAR(50);

    
    SELECT COUNT(*) INTO library_operator_approved
    FROM library_operator
    WHERE library_operator_username = operator_username AND approved = 1;
    
    IF library_operator_approved > 0 THEN
        
        SELECT school_name INTO library_operator_school
        FROM school_member
        WHERE school_member_username = operator_username;
        
        SELECT school_name INTO teacherstudent_school
        FROM school_member
        WHERE school_member_username = teacherstudent_username;
        
        IF library_operator_school = teacherstudent_school THEN
            
            UPDATE teacherstudent
            SET approved = 0
            WHERE username = teacherstudent_username;
            
            SELECT 'School member account disabled successfully.' AS message;
        ELSE
            SELECT 'Library operator and member belong to different schools.' AS message;
        END IF;
    ELSE
        SELECT 'Library operator is not approved.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_authors_not_borrowed` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_authors_not_borrowed`()
BEGIN
    
 SELECT DISTINCT ba.author_name
    FROM book_author ba
    WHERE ba.author_name NOT IN(
        SELECT DISTINCT ba.author_name
        FROM book_author ba
        WHERE ba.book_id IN (
            SELECT book_id FROM reserves 
        )
    );

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_authors_with_less_books` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_authors_with_less_books`()
BEGIN
    DECLARE max_books INT;

    
    SELECT COUNT(DISTINCT b.title) INTO max_books
    FROM book_author ba
    JOIN book b ON ba.book_id = b.book_id
    GROUP BY ba.author_name
    ORDER BY COUNT(DISTINCT b.title) DESC
    LIMIT 1;

    SELECT ba.author_name, COUNT(DISTINCT b.title) AS title_count
    FROM book_author ba
    JOIN book b ON ba.book_id = b.book_id
    GROUP BY ba.author_name
    HAVING title_count <= (max_books - 5)
    ORDER BY title_count DESC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_book_information` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_book_information`(
    IN bookId INT
)
BEGIN
    SELECT b.ISBN, b.title, b.pages_number, b.publisher, b.summary, b.language,
        GROUP_CONCAT(DISTINCT ba.author_name SEPARATOR ', ') AS authors,
        GROUP_CONCAT(DISTINCT bc.category SEPARATOR ', ') AS categories,
        GROUP_CONCAT(DISTINCT bk.keyword SEPARATOR ', ') AS keywords
    FROM book b
    LEFT JOIN book_author ba ON b.book_id = ba.book_id
    LEFT JOIN book_category bc ON b.book_id = bc.book_id
    LEFT JOIN book_keyword bk ON b.book_id = bk.book_id
    WHERE b.book_id = bookId
    GROUP BY b.book_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `login_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `login_user`(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(50)
)
BEGIN
    DECLARE user_count INT;
    DECLARE is_approved INT;
    DECLARE is_library_operator INT;
    DECLARE password_count INT;
    DECLARE isteacher INT;
    DECLARE library_operator_approved INT;

    IF p_username = 'admin' THEN

        SELECT COUNT(*) INTO user_count
        FROM user
        WHERE username = p_username AND password = p_password;

        IF user_count > 0 THEN
            SELECT 'Admin login successful.' AS message;
        ELSE
            SELECT 'Wrong password.' AS message;
        END IF;
    ELSE
        SELECT COUNT(*) INTO user_count
        FROM user
        WHERE username = p_username;

        IF user_count = 0 THEN
            SELECT 'You are not registered in the system.' AS message;
        ELSE
            SELECT COUNT(*) INTO password_count
            FROM user
            WHERE username = p_username AND password = p_password;

            IF password_count = 0 THEN
                SELECT 'Wrong password.' AS message;
            ELSE
                SELECT COUNT(*) INTO is_library_operator
                FROM library_operator
                WHERE library_operator_username = p_username;

                IF is_library_operator > 0 THEN
                    SELECT approved INTO is_approved
                    FROM library_operator
                    WHERE library_operator_username = p_username;
                                    
                    IF is_approved <> 1 THEN
                        SELECT 'You are not an approved school member yet.' AS message;
                    ELSE
                        SELECT 'Library operator login successful.' AS message;
                    END IF;
                ELSE
                    SELECT approved INTO is_approved
                    FROM teacherstudent
                    WHERE username = p_username;

                    IF is_approved <> 1 THEN
                        SELECT 'You are not an approved school member yet.' AS message;
                    ELSE

                        SELECT COUNT(*) INTO library_operator_approved
                        FROM library_operator lo
                        JOIN school_member sm ON lo.library_operator_username = sm.school_member_username
                        WHERE approved = 1 AND sm.school_name = (SELECT school_name FROM school_member WHERE school_member_username = p_username);

                        IF library_operator_approved >0 THEN 
                            SELECT COUNT(*) INTO isteacher
                            FROM teacherstudent
                            WHERE username = p_username AND position = 'teacher';

                            IF isteacher > 0 THEN
                                SELECT 'Teacher login successful.' AS message;
                            ELSE 
                                SELECT 'Student login successful.' AS message;
                            END IF;

                        ELSE 

                            SELECT 'Your school does not have an approved library operator.' AS message;

                        END IF ;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `make_reservation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `make_reservation`(
    IN p_teacherstudent_username VARCHAR(50),
    IN p_book_id INT
)
BEGIN
    DECLARE is_approved INT;
    DECLARE library_operator_username_temp VARCHAR(50);
    
        
        SELECT library_operator_username INTO library_operator_username_temp
        FROM library_operator l
        JOIN school_member s ON l.library_operator_username = s.school_member_username
        WHERE s.school_name = (
            SELECT school_name
            FROM school_member
            WHERE school_member_username = p_teacherstudent_username
        ) AND l.approved = 1;
        
        INSERT INTO reservation (username, book_id, reservation_date, library_operator_username, status)
        VALUES (p_teacherstudent_username, p_book_id, CURDATE(), library_operator_username_temp, NULL);
        SELECT 'Successful reservation.' AS message;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `most_famous_field_pair` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `most_famous_field_pair`()
BEGIN 

    SELECT DISTINCT LEAST(c1.category, c2.category) AS category1, GREATEST(c1.category, c2.category) AS category2
    FROM book_category c1
    JOIN book_category c2 ON c1.book_id = c2.book_id AND c1.category <> c2.category
    JOIN reserves r ON r.book_id = c1.book_id
    GROUP BY c1.category, c2.category
    ORDER BY COUNT(*) DESC
    LIMIT 3;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_reviews` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_reviews`(
    IN username_param VARCHAR(50)
)
BEGIN
    DECLARE user_approved INT ;

    SELECT COUNT(*) INTO user_approved
    FROM teacherstudent
    WHERE username = username_param AND approved = 1;

    IF user_approved >0 THEN 

        SELECT r.title, r.likert_rating, r.text, r.review_id,
        CASE WHEN r.approved = 1 THEN 'Approved' ELSE 'Not approved' END
        FROM review r 
        WHERE r.user_username = username_param;
    ELSE 
        SELECT 'You are not an approved school member. Please contact your school''s library operator for approval.' AS message;
    END IF;   
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `record_loan_without_reservation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `record_loan_without_reservation`(
    IN operator_username VARCHAR(50),
    IN user_username VARCHAR(50),
    IN my_book_id VARCHAR(100)
)
BEGIN  
    DECLARE operator_approved INT;
    DECLARE user_approved INT;
    DECLARE num_books_allowed INT;
    DECLARE current_week_loan_count INT;
    DECLARE current_week_reservation_count INT;
    DECLARE has_reserved_book INT;
    DECLARE has_delayed_return INT;
    DECLARE operator_school_name VARCHAR(100);
    DECLARE teacherstudent_school_name VARCHAR(100);
    DECLARE available_copies INT;
    DECLARE my_title VARCHAR(200);
    DECLARE book_exists INT;
    DECLARE my_reservation_id INT;
    
    SELECT COUNT(*) INTO operator_approved
    FROM library_operator
    WHERE library_operator_username = operator_username AND approved = 1;

    SELECT COUNT(*) INTO user_approved
    FROM teacherstudent
    WHERE username = user_username AND approved = 1;
    
    IF operator_approved > 0 THEN

        IF user_approved > 0 THEN 

            SELECT school_name INTO operator_school_name
            FROM school_member
            WHERE school_member_username = operator_username;

            SELECT school_name INTO teacherstudent_school_name
            FROM school_member
            WHERE school_member_username = user_username;

            IF operator_school_name = teacherstudent_school_name THEN 

                SELECT COUNT(*) INTO book_exists
                FROM book
                WHERE book_id = my_book_id AND library_operator_username = operator_username;

                IF book_exists > 0 THEN
        
                    SELECT num_of_books_allowed INTO num_books_allowed
                    FROM teacherstudent
                    WHERE username = user_username;
        
                    SELECT COUNT(*) INTO current_week_loan_count
                    FROM reserves
                    WHERE username = user_username
                    AND borrow_date > DATE_SUB(CURDATE(), INTERVAL 1 WEEK);
        
                    SELECT COUNT(*) INTO current_week_reservation_count
                    FROM reservation
                    WHERE username = user_username
                    AND status = 'pending';

                    SELECT title INTO my_title
                    FROM book
                    WHERE book_id = my_book_id;

                    SELECT COUNT(*) INTO has_reserved_book
                    FROM reservation r
                    JOIN book b ON r.book_id = b.book_id
                    WHERE username = user_username AND b.title = my_title AND status = 'pending';
        
                    SELECT COUNT(*) INTO has_delayed_return
                    FROM reserves
                    WHERE username = user_username AND returned_date IS NULL AND due_date < CURDATE();
        
                    IF (current_week_loan_count < num_books_allowed AND current_week_reservation_count < num_books_allowed AND has_reserved_book = 0 AND has_delayed_return = 0) THEN

                        IF EXISTS (
                            SELECT 1
                            FROM reserves
                            WHERE book_id = my_book_id AND returned_date IS NULL
                        ) THEN
                            SELECT 'Book is unavailable.' AS message;

                        ELSE
                            INSERT INTO reservation (username, book_id, reservation_date, library_operator_username, status)
                            VALUES (user_username, my_book_id, CURDATE(), operator_username, 'skipped');

                            SET my_reservation_id = LAST_INSERT_ID();

                            INSERT INTO reserves (reservation_id, book_id, borrow_date, returned_date, due_date, username) 
                            VALUES (my_reservation_id, my_book_id, CURDATE(), NULL, DATE_ADD(CURDATE(), INTERVAL 7 DAY), user_username);

                            SELECT 'Loan recorded successfully.' AS message;
                        END IF;
                    ELSE
                        SELECT 'Loan criteria not met.' AS message;
                    END IF;
                ELSE
                    SELECT 'Book does not exist' AS message;
                END IF;
            ELSE 
                SELECT 'You and the user do not belong to the same school.' AS message;
            END IF;
        ELSE 
            SELECT 'School member does not exist or is not approved.' AS message;
        END IF;
    ELSE
        SELECT 'Unauthorized library operator.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `record_returned_books` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `record_returned_books`(
    IN p_reservation_id INT,
    IN p_library_operator_username VARCHAR(50)
)
BEGIN
    DECLARE operator_approved INT;
    DECLARE reservation_id_exists INT;
    DECLARE return_already_recorded INT;
    
    SELECT approved INTO operator_approved
    FROM library_operator
    WHERE library_operator_username = p_library_operator_username;
    
    IF operator_approved = 1 THEN

        SELECT COUNT(*) INTO reservation_id_exists
        FROM reserves
        WHERE reservation_id = p_reservation_id;

        If reservation_id_exists > 0 THEN

            SELECT COUNT(*) INTO return_already_recorded
            FROM reserves
            WHERE reservation_id = p_reservation_id AND returned_date IS NOT NULL;

            IF return_already_recorded = 0 THEN
        
                UPDATE reserves
                SET returned_date = CURDATE()
                WHERE reservation_id = p_reservation_id;
        
                SELECT 'Returned date recorded successfully.' AS message;
            ELSE 
                SELECT 'Return already recorded.' AS message;
            END IF;
        ELSE 
            SELECT 'The reservation ID you entered is not valid.' AS message;
        END IF;
    ELSE
        SELECT 'You are not an approved library operator.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_school` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `register_school`(
    IN my_school_name VARCHAR(75),
    IN my_city VARCHAR(70),
    IN my_email VARCHAR(50),
    IN my_school_director_first_name VARCHAR(20),
    IN my_school_director_last_name VARCHAR(50),
    IN my_street_number VARCHAR(5),
    IN my_street_name VARCHAR(30),
    IN my_zip_code INT(11),
    IN my_phone_number VARCHAR(30)
)
BEGIN
    DECLARE school_exists INT;
    
    SELECT COUNT(*) INTO @user_count FROM administrator WHERE username = 'admin';
    IF (@user_count = 0) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'You are not authorized to add a school.';
    END IF;

    SELECT COUNT(*) INTO school_exists
    FROM school
    WHERE school_name = my_school_name;

    IF school_exists = 0 THEN 
    
        INSERT INTO school (school_name, city, email, school_director_first_name, school_director_last_name, library_operator_first_name, library_operator_last_name, street_number, street_name, zip_code, school_phone_number, administrator_username) VALUES (my_school_name, my_city, my_email, my_school_director_first_name, my_school_director_last_name, NULL, NULL, my_street_number, my_street_name, my_zip_code, my_phone_number, 'admin');

        SELECT 'Done!! Now school is in the base!' AS message;
    ELSE
        SELECT 'School already exists.' AS message;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_authors_per_category` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `search_authors_per_category`(
    IN book_category VARCHAR(50) 
)
BEGIN

    SELECT DISTINCT a.author_name 
    FROM book_author a
    INNER JOIN book_category c ON c.book_id = a.book_id
    WHERE (
        c.category = book_category
    )
    GROUP BY a.author_name;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_books_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `search_books_library_operator`(
    IN user_username_param VARCHAR(50),
    IN title_searched VARCHAR(100),
    IN category_searched VARCHAR(100),
    IN author_searched VARCHAR(100),
    IN copies_searched INT
)
BEGIN
    SELECT b.title, GROUP_CONCAT(DISTINCT a.author_name SEPARATOR ', ') AS authors
    FROM book b
    JOIN book_author a ON b.book_id = a.book_id
    JOIN book_category c ON b.book_id= c.book_id
    WHERE b.school_name = (
        SELECT school_name
        FROM school_member
        WHERE school_member_username = user_username_param)
    AND ((title_searched IS NULL OR title_searched = '') OR b.title = title_searched)
    AND ((author_searched IS NULL OR author_searched = '') OR b.book_id IN (
        SELECT book_id
        FROM book_author
        WHERE author_name = author_searched
    ))
    AND ((category_searched IS NULL OR category_searched = '') OR c.category = category_searched)
    AND ((copies_searched IS NULL ) OR (SELECT COUNT(*) FROM book WHERE title = b.title AND school_name = b.school_name) = copies_searched)
    GROUP BY b.title;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_borrowers_with_delayed_returns` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `search_borrowers_with_delayed_returns`(
    IN library_operator_username_param VARCHAR(50),
    IN first_name_searched VARCHAR(50),
    IN last_name_searched VARCHAR(50),
    IN days_delayed_searched INT
)
BEGIN
    SELECT u.username, u.first_name, u.last_name, DATEDIFF(CURDATE(), r.due_date)
    FROM user u
    JOIN reserves r ON u.username = r.username
    JOIN school_member s ON r.username = s.school_member_username
    WHERE s.school_name = (
        SELECT school_name 
        FROM school_member
        WHERE school_member_username = library_operator_username_param
    )
    AND r.returned_date IS NULL
    AND DATEDIFF(CURDATE(), r.due_date) > 0
    AND (
        (first_name_searched IS NULL OR first_name_searched = '') OR u.first_name = first_name_searched
    )
    AND (
        (last_name_searched IS NULL OR last_name_searched = '') OR u.last_name = last_name_searched
    )
    AND (
        (days_delayed_searched IS NULL) OR DATEDIFF(CURDATE(), r.due_date) = days_delayed_searched
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_loans_per_school` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `search_loans_per_school`(
    IN searchYear INT,
    IN searchMonth VARCHAR(50)
)
BEGIN
    DECLARE monthValue INT;

    
    IF searchMonth IS NOT NULL THEN
        SET monthValue = CASE searchMonth
            WHEN 'January' THEN 1
            WHEN 'February' THEN 2
            WHEN 'March' THEN 3
            WHEN 'April' THEN 4
            WHEN 'May' THEN 5
            WHEN 'June' THEN 6
            WHEN 'July' THEN 7
            WHEN 'August' THEN 8
            WHEN 'September' THEN 9
            WHEN 'October' THEN 10
            WHEN 'November' THEN 11
            WHEN 'December' THEN 12
            ELSE NULL
        END;
    ELSE
        SET monthValue = NULL;
    END IF;

    SELECT s.school_name, COUNT(*) AS occurrences
    FROM school_member s
    INNER JOIN reserves r ON s.school_member_username = r.username
    WHERE (
        (searchYear IS NULL OR YEAR(r.borrow_date) = searchYear)
        AND
        (monthValue IS NULL OR MONTH(r.borrow_date) = monthValue)
    )
    GROUP BY s.school_name
    ORDER BY occurrences DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_operators_num_of_loans_per_year` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `search_operators_num_of_loans_per_year`(
    IN searchYear INT
    )
BEGIN

    SELECT subquery.occurrences, COUNT(*) AS num_operators, GROUP_CONCAT(subquery.library_operator_username) AS operator_usernames
    FROM (
        SELECT r.library_operator_username, COUNT(*) AS occurrences
        FROM reservation r
        WHERE (r.status = "loaned" OR r.status = "skipped" )
        AND (YEAR(r.reservation_date) = searchYear)
        GROUP BY r.library_operator_username
        HAVING occurrences > 20
    ) AS subquery
    GROUP BY subquery.occurrences
    ORDER BY subquery.occurrences DESC;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_teachers_per_book_loaned_category` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `search_teachers_per_book_loaned_category`(
    IN book_category VARCHAR(50) 
)
BEGIN
    
    SELECT u.username, u.first_name, u.last_name
    FROM user u
    INNER JOIN teacherstudent t ON u.username = t.username
    INNER JOIN reserves r ON t.username = r.username
    WHERE position = "teacher" AND
    YEAR(r.borrow_date) = YEAR(CURDATE()) AND r.book_id IN (
        SELECT r.book_id
        FROM reserves r 
        INNER JOIN book_category c ON c.book_id = r.book_id
        WHERE (
            c.category = book_category
        )
    )
    GROUP BY u.username;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `search_user`(    IN user_username VARCHAR(20))
BEGIN    SELECT ts.position, u.first_name, u.last_name, ts.approved    FROM user u    JOIN teacherstudent ts ON u.username = ts.username    WHERE u.username = user_username;END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_user_from_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `search_user_from_library_operator`(    IN operator_username VARCHAR(20))
BEGIN    DECLARE operator_approved INT;    SELECT COUNT(*) INTO operator_approved    FROM library_operator    WHERE library_operator_username = operator_username AND approved = 1;    IF operator_approved > 0 THEN        SELECT u.username, ts.position, u.first_name, u.last_name, ts.approved        FROM user u        JOIN teacherstudent ts ON u.username = ts.username        JOIN school_member sm ON u.username = sm.school_member_username        WHERE sm.school_name = (                SELECT school_name FROM school_member WHERE school_member_username = operator_username            )        ORDER BY CASE WHEN ts.approved = 0 THEN 1 ELSE 2 END, u.username;    ELSE        SELECT 'You are not an approved school member. Please contact your school''s library operator for approval.' AS message;    END IF;END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_book`(
    IN my_book_id INT,
    IN new_isbn VARCHAR(50),
    IN new_title VARCHAR(100),
    IN new_pages_number INT,
    IN new_publisher VARCHAR(50),
    IN new_summary TEXT,
    IN new_image BLOB,
    IN operator_username VARCHAR(50),
    IN new_language VARCHAR(20),
    IN new_authors VARCHAR(255),
    IN new_categories VARCHAR(255),
    IN new_keywords VARCHAR(255)
)
BEGIN
    DECLARE operator_count INT;
    DECLARE operator_school_name VARCHAR(100);
    DECLARE copy_counter INT;
    DECLARE author_string VARCHAR(255); 
    DECLARE category_string VARCHAR(255); 
    DECLARE keyword_string VARCHAR(255); 
    
    SELECT COUNT(*) INTO operator_count
    FROM library_operator
    WHERE library_operator_username = operator_username
      AND approved = 1;
    
    IF operator_count > 0 THEN
        
        SELECT school_name INTO operator_school_name
        FROM school_member
        WHERE school_member_username = operator_username;
        
        UPDATE book
        SET isbn = new_isbn,
            title = new_title,
            school_name = operator_school_name,
            pages_number = new_pages_number,
            publisher = new_publisher,
            summary = new_summary,
            image = new_image,
            library_operator_username = operator_username,
            language = new_language
        WHERE book_id = my_book_id;
        
        
        DELETE FROM book_author WHERE book_id = my_book_id;
        DELETE FROM book_category WHERE book_id = my_book_id;
        DELETE FROM book_keyword WHERE book_id = my_book_id;
        
        IF new_authors IS NOT NULL THEN
            SET author_string = new_authors; 
            WHILE LENGTH(TRIM(author_string)) > 0 DO
                SET @author = SUBSTRING_INDEX(author_string, ',', 1);
                SET author_string = 
                    TRIM(SUBSTRING(author_string, LENGTH(@author) + 2));
                    
                INSERT INTO book_author (book_id, author_name)
                VALUES (my_book_id, TRIM(@author));
            END WHILE;
        END IF;
        
        IF new_categories IS NOT NULL THEN
            SET category_string = new_categories; 
            WHILE LENGTH(TRIM(category_string)) > 0 DO
                SET @category = SUBSTRING_INDEX(category_string, ',', 1);
                SET category_string = 
                    TRIM(SUBSTRING(category_string, LENGTH(@category) + 2));
                    
                INSERT INTO book_category (book_id, category)
                VALUES (my_book_id, TRIM(@category));
            END WHILE;
        END IF;
        
        IF new_keywords IS NOT NULL THEN
            SET keyword_string = new_keywords; 
            WHILE LENGTH(TRIM(keyword_string)) > 0 DO
                SET @keyword = SUBSTRING_INDEX(keyword_string, ',', 1);
                SET keyword_string = 
                    TRIM(SUBSTRING(keyword_string, LENGTH(@keyword) + 2));
                    
                INSERT INTO book_keyword (book_id, keyword)
                VALUES (my_book_id, TRIM(@keyword));
            END WHILE;
        END IF;

        SELECT 'Book updated successfully.' AS message;
    ELSE 
        SELECT 'You are not an approved library operator.' AS message;
    END IF;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_teacher_information` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_teacher_information`(
    IN p_username VARCHAR(50),
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_date_of_birth DATE,
    IN p_email VARCHAR(100),
    IN p_phone_number VARCHAR(20)
)
BEGIN
    DECLARE is_student INT;

    SELECT COUNT(*) INTO is_student
    FROM teacherstudent ts
    JOIN user u ON ts.username = u.username
    WHERE ts.username = p_username AND ts.position = 'student';

    
    IF is_student = 0 THEN
        UPDATE user
        SET first_name = p_first_name,
            last_name = p_last_name,
            date_of_birth = p_date_of_birth,
            email = p_email
        WHERE username = p_username;
        
        SELECT 'Personal information updated successfully.' AS message;
    ELSE
        SELECT 'Can''t update personal information.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `user_average_rating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_average_rating`(
    IN library_operator_username_param VARCHAR(50),
    IN username_param VARCHAR(50)
)
BEGIN
    SELECT r.user_username, AVG(r.likert_rating)
    FROM review r
    JOIN school_member s ON r.user_username=s.school_member_username
    WHERE ((username_param IS NULL OR username_param = '') OR r.user_username = username_param) AND r.approved =1 
    AND s.school_name = (SELECT school_name FROM school_member WHERE school_member_username = library_operator_username_param);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_books_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_books_library_operator`(
    IN operator_username VARCHAR(50)
)
BEGIN
    DECLARE operator_school_name VARCHAR(50);
    DECLARE is_approved INT;

    
    SELECT school_name INTO operator_school_name FROM school_member WHERE school_member_username = operator_username;

    
    SELECT approved INTO is_approved FROM library_operator WHERE library_operator_username = operator_username;
    IF is_approved <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'You are not an approved library operator.';
    END IF;

    
    SELECT * FROM book WHERE school_name = operator_school_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_book_authors_teacherstudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_book_authors_teacherstudent`(
    IN p_teacherstudent_username VARCHAR(50),
    IN p_title VARCHAR(100)
)
BEGIN
    DECLARE book_id_temp INT;
    DECLARE v_school_name VARCHAR(50);
    

    SELECT school_name INTO v_school_name
    FROM school_member
    WHERE school_member_username = p_teacherstudent_username;

    SET book_id_temp = (
        SELECT DISTINCT book_id
        FROM book 
        WHERE title = p_title AND school_name= v_school_name
        LIMIT 1
    );
        
    IF book_id_temp IS NOT NULL THEN
        SELECT author_name 
        FROM book_author
        WHERE book_id = book_id_temp;
    END IF;


    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_book_categories_teacherstudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_book_categories_teacherstudent`(
    IN p_teacherstudent_username VARCHAR(50),
    IN p_title VARCHAR(100)
)
BEGIN
    DECLARE book_id_temp INT;
    DECLARE v_school_name VARCHAR(50);
    

    SELECT school_name INTO v_school_name
    FROM school_member
    WHERE school_member_username = p_teacherstudent_username;

    SET book_id_temp = (
        SELECT DISTINCT book_id
        FROM book 
        WHERE title = p_title AND school_name= v_school_name
        LIMIT 1
    );
        
    IF book_id_temp IS NOT NULL THEN
        SELECT category 
        FROM book_category
        WHERE book_id = book_id_temp;
    END IF;


    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_book_details_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_book_details_library_operator`(
    IN p_library_operator_username VARCHAR(50),
    IN p_title VARCHAR(100)
)
BEGIN
    DECLARE is_approved INT;
    DECLARE v_school_name VARCHAR(50);

    
    SELECT COUNT(*) INTO is_approved
    FROM library_operator
    WHERE library_operator_username = p_library_operator_username AND approved = 1;

    
    SELECT school_name INTO v_school_name
    FROM school_member
    WHERE school_member_username = p_library_operator_username;

    IF is_approved > 0 THEN
        
        SELECT DISTINCT ISBN, pages_number, publisher, summary, language
        FROM book 
        WHERE school_name = v_school_name AND title = p_title;
    ELSE
        
        SELECT 'You are not approved to view books of the school. Please contact your school''s library operator for approval.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_book_details_teacherstudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_book_details_teacherstudent`(
    IN p_teacherstudent_username VARCHAR(50),
    IN p_title VARCHAR(100)
)
BEGIN
    DECLARE is_approved INT;
    DECLARE v_school_name VARCHAR(50);

    
    SELECT COUNT(*) INTO is_approved
    FROM teacherstudent
    WHERE username = p_teacherstudent_username AND approved = 1;

    
    SELECT school_name INTO v_school_name
    FROM school_member
    WHERE school_member_username = p_teacherstudent_username;

    IF is_approved > 0 THEN
        
        SELECT DISTINCT ISBN, pages_number, publisher, summary, language
        FROM book 
        WHERE school_name = v_school_name AND title = p_title;
    ELSE
        
        SELECT 'You are not approved to view books of the school. Please contact your school''s library operator for approval.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_book_ids` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_book_ids`(
    IN p_teacherstudent_username VARCHAR(50),
    IN p_title VARCHAR(100)
)
BEGIN
    DECLARE is_approved INT;
    DECLARE v_school_name VARCHAR(50);

    
    SELECT COUNT(*) INTO is_approved
    FROM teacherstudent
    WHERE username = p_teacherstudent_username AND approved = 1;

    
    SELECT school_name INTO v_school_name
    FROM school_member
    WHERE school_member_username = p_teacherstudent_username;

    IF is_approved > 0 THEN
        
        SELECT book_id
        FROM book 
        WHERE school_name = v_school_name AND title = p_title;
    ELSE
        
        SELECT 'You are not approved to view books of the school. Please contact your school''s library operator for approval.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_book_keywords_teacherstudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_book_keywords_teacherstudent`(
    IN p_teacherstudent_username VARCHAR(50),
    IN p_title VARCHAR(100)
)
BEGIN
    DECLARE book_id_temp INT;
    DECLARE v_school_name VARCHAR(50);
    

    SELECT school_name INTO v_school_name
    FROM school_member
    WHERE school_member_username = p_teacherstudent_username;

    SET book_id_temp = (
        SELECT DISTINCT book_id
        FROM book 
        WHERE title = p_title AND school_name= v_school_name
        LIMIT 1
    );
        
    IF book_id_temp IS NOT NULL THEN
        SELECT keyword
        FROM book_keyword
        WHERE book_id = book_id_temp;
    END IF;


    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_book_titles_teacherstudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_book_titles_teacherstudent`(
    IN p_teacherstudent_username VARCHAR(50)
)
BEGIN
    DECLARE is_approved INT;
    DECLARE v_school_name VARCHAR(50);

    
    SELECT COUNT(*) INTO is_approved
    FROM teacherstudent
    WHERE username = p_teacherstudent_username AND approved = 1;

    
    SELECT school_name INTO v_school_name
    FROM school_member
    WHERE school_member_username = p_teacherstudent_username;

    IF is_approved > 0 THEN
        
        SELECT DISTINCT title
        FROM book 
        WHERE school_name = v_school_name;
    ELSE
        
        SELECT 'You are not approved to view books of the school. Please contact your school''s library operator for approval.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_delays_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_delays_library_operator`(
    IN operator_username VARCHAR(50)
)
BEGIN
    DECLARE operator_school_name VARCHAR(50);
    DECLARE operator_approved INT;

    
    SELECT s.school_name, l.approved INTO operator_school_name, operator_approved
    FROM library_operator l
    INNER JOIN school_member s ON s.school_member_username = l.library_operator_username
    WHERE l.library_operator_username = operator_username;

    
    IF operator_approved = 1 THEN
        
        SELECT r.reservation_id, r.username,t.position , b.book_id, b.title , r.borrow_date ,r.due_date, r.returned_date,
        CASE WHEN r.returned_date IS NOT NULL THEN 'yes' ELSE 'no' END 
        FROM reserves r
        INNER JOIN teacherstudent t ON t.username = r.username
        INNER JOIN school_member s on s.school_member_username = r.username
        INNER JOIN book b ON b.book_id = r.book_id
        WHERE  (
            operator_school_name = s.school_name
        )
        AND (
            r.returned_date > r.due_date OR 
            (r.returned_date IS NULL AND r.due_date < CURDATE())
        )
        ORDER BY r.borrow_date DESC;

    ELSE 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unauthorized action.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_loans_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_loans_library_operator`(
    IN operator_username VARCHAR(50)
)
BEGIN
    DECLARE operator_school_name VARCHAR(50);
    DECLARE operator_approved INT;

    
    SELECT s.school_name, l.approved INTO operator_school_name, operator_approved
    FROM library_operator l
    INNER JOIN school_member s ON s.school_member_username = l.library_operator_username
    WHERE l.library_operator_username = operator_username;

    
    IF operator_approved = 1 THEN
        
        SELECT r.reservation_id, r.username,t.position , b.book_id, b.title , r.borrow_date ,r.due_date, r.returned_date,
        CASE WHEN r.returned_date IS NOT NULL THEN 'yes' ELSE 'no' END 
        FROM reserves r
        INNER JOIN teacherstudent t ON t.username = r.username
        INNER JOIN school_member s on s.school_member_username = r.username
        INNER JOIN book b ON b.book_id = r.book_id
        WHERE  (
            operator_school_name = s.school_name
        )
        ORDER BY CASE WHEN r.returned_date IS NULL
        THEN 1 ELSE 2 END, r.borrow_date DESC;

    ELSE 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unauthorized action.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_loans_teacherstudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_loans_teacherstudent`(
  IN `teacherstudent_username` VARCHAR(50)
)
BEGIN 
    
    SELECT r.reservation_id, r.username,t.position , b.book_id, b.title , r.borrow_date ,r.due_date, r.returned_date,
    CASE WHEN r.returned_date IS NOT NULL THEN 'yes' ELSE 'no' END 
    FROM reserves r
    INNER JOIN teacherstudent t ON t.username = r.username
    INNER JOIN book b ON b.book_id = r.book_id
    WHERE  (
         r.username = teacherstudent_username
    )
    ORDER BY CASE WHEN r.returned_date IS NULL
    THEN 1 ELSE 2 END, r.borrow_date DESC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_pending_reviews` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_pending_reviews`(
    IN p_library_operator_username VARCHAR(50)
)
BEGIN
    
    DECLARE is_approved INT;
    DECLARE operator_school_name VARCHAR(100);
    SELECT COUNT(*) INTO is_approved
    FROM library_operator
    WHERE library_operator_username = p_library_operator_username AND approved = 1;

SELECT school_name INTO operator_school_name
FROM school_member
WHERE school_member_username = p_library_operator_username;

    
    IF is_approved > 0 THEN
        SELECT r.review_id, r.book_title, r.text, r.likert_rating, r.library_operator_username, r.user_username
        FROM review r
        JOIN school_member sm ON r.user_username = sm.user_username
        WHERE r.approved = 0 AND sm.school_name = operator_school_name;
    ELSE
        SELECT 'You are not an approved library operator.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_reservations_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_reservations_library_operator`(
    IN `operator_username` VARCHAR(50)
)
BEGIN
    DECLARE operator_approved INT;
    DECLARE operator_school_name VARCHAR(100);
    
    SELECT approved INTO operator_approved
    FROM library_operator l
    WHERE l.library_operator_username = operator_username;

    

    IF operator_approved = 1 THEN

        SELECT school_name INTO operator_school_name
        FROM school_member
        WHERE school_member_username = operator_username;
        
        SELECT r.reservation_id,r.username, t.position ,r.book_id, b.title ,r.reservation_date, r.status
        FROM reservation r
        INNER JOIN teacherstudent t ON t.username = r.username
        INNER JOIN school_member s on s.school_member_username = r.username
        INNER JOIN book b ON b.book_id = r.book_id
        WHERE  (
            operator_school_name = s.school_name
        )
        ORDER BY CASE WHEN r.status = "pending" 
        THEN 1 ELSE 2 END, r.reservation_date DESC;
        
    ELSE

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unauthorized action.';

    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_reservations_teacherstudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_reservations_teacherstudent`(
  IN `teacherstudent_username` VARCHAR(50)
)
BEGIN

    SELECT r.reservation_id,r.username, t.position ,r.book_id, b.title ,r.reservation_date, r.status
    FROM reservation r
    INNER JOIN teacherstudent t ON t.username = r.username
    INNER JOIN book b ON b.book_id = r.book_id
    WHERE r.username = teacherstudent_username
    ORDER BY CASE WHEN r.status = "pending" 
    THEN 1 ELSE 2 END, r.reservation_date DESC;   

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_reviews_library_operator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_reviews_library_operator`(
    IN username_param VARCHAR(50)
)
BEGIN 
    DECLARE user_approved INT ;

    SELECT COUNT(*) INTO user_approved
    FROM library_operator
    WHERE library_operator_username = username_param AND approved = 1;

    IF user_approved >0 THEN 
    SELECT r.review_id, r.title, r.likert_rating, r.text, r.user_username,
    CASE WHEN r.approved = 1 THEN 'Approved' ELSE 'Not approved' END
    FROM review r 
    JOIN school_member sm ON r.user_username = sm.school_member_username
    WHERE sm.school_name = (SELECT school_name FROM school_member
        WHERE school_member_username = username_param)
    ORDER BY CASE WHEN r.approved = 0 THEN 1 ELSE 2 END, r.review_id;

    ELSE 
        SELECT 'You are not an approved library operator.' AS message;
    END IF;   
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_reviews_per_title` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_reviews_per_title`(
    IN title_param VARCHAR(100),
    IN user_username_param VARCHAR(50)
)
BEGIN 
    DECLARE user_approved INT ;

    SELECT COUNT(*) INTO user_approved
    FROM teacherstudent
    WHERE username = user_username_param AND approved = 1;

    IF user_approved >0 THEN 

        SELECT r.text, r.likert_rating, sm.school_member_username
        FROM review r
        JOIN school_member sm ON r.user_username = sm.school_member_username
        WHERE r.title = title_param AND sm.school_name = (
            SELECT school_name FROM school_member WHERE school_member_username = user_username_param
        ) AND r.approved =1;
    ELSE 
        SELECT 'You are not an approved school member. Please contact your school''s library operator for approval.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_user_information` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_user_information`(
    IN p_username VARCHAR(50)
)
BEGIN
    DECLARE user_exists INT;
    DECLARE is_library_operator INT;
    DECLARE is_admin INT;
    
    SELECT COUNT(*) INTO user_exists
    FROM user
    WHERE username = p_username;
    
    IF user_exists > 0 THEN
        SELECT COUNT(*) INTO is_library_operator
        FROM library_operator
        WHERE library_operator_username = p_username;

        SELECT COUNT(*) INTO is_admin
        FROM administrator
        WHERE username = p_username;

        IF is_admin > 0 THEN 
            SELECT u.username, u.first_name, u.last_name, u.date_of_birth, u.email, u.phone_number, '-', 'administrator'
            FROM user u
            WHERE u.username = p_username;

        ELSEIF is_library_operator > 0 THEN 
            SELECT u.username, u.first_name, u.last_name, u.date_of_birth, u.email, u.phone_number, s.school_name, 'library operator'
            FROM user u
            INNER JOIN school_member s ON u.username = s.school_member_username
            INNER JOIN library_operator l ON u.username = l.library_operator_username
            WHERE u.username = p_username;
        
        ELSE 
            SELECT u.username, u.first_name, u.last_name, u.date_of_birth, u.email, u.phone_number, s.school_name, t.position
            FROM user u
            INNER JOIN school_member s ON u.username = s.school_member_username
            INNER JOIN teacherstudent t ON u.username = t.username
            WHERE u.username = p_username;
        
        END IF;
    ELSE
        SELECT 'User not found.' AS message;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `young_teachers_most_reserves` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `young_teachers_most_reserves`()
BEGIN

    SELECT u.username, u.first_name, u.last_name, COUNT(*) AS occurrences
    FROM user u
    INNER JOIN teacherstudent t ON u.username = t.username
    INNER JOIN reserves r ON t.username = r.username
    WHERE position = "teacher" AND
    date_of_birth > DATE_SUB(CURDATE(), INTERVAL 40 YEAR)
    GROUP BY u.username
    ORDER BY occurrences DESC;

END ;;
DELIMITER ;


CREATE INDEX idx_book_title_school ON book(title, school_name);
CREATE INDEX idx_school_member_username_school ON school_member(school_member_username, school_name);
CREATE INDEX idx_teacherstudent_username_position ON teacherstudent(username, position);
CREATE INDEX idx_reserves_username ON reserves(username);
CREATE INDEX idx_review_username ON review(user_username);
CREATE INDEX idx_reserves_return_date ON reserves(returned_date);
CREATE INDEX idx_reserves_due_date ON reserves(due_date);
CREATE INDEX idx_reserves_borrow_date ON reserves(borrow_date);




/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-06-04 23:33:13
