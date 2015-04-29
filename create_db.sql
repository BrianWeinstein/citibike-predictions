-- mysql -u andy -pasdf1234 socialdata;
CREATE DATABASE IF NOT EXISTS `socialdata` /*!40100 DEFAULT CHARACTER SET utf8 */;

CREATE TABLE IF NOT EXISTS `socialdata`.`mta_raw` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sent_date` datetime DEFAULT NULL,
  `agency` varchar(15) DEFAULT NULL,
  `subject` varchar(400) DEFAULT NULL,
  `message` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sent_date` (`sent_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

TRUNCATE TABLE `socialdata`.`mta_raw`;

LOAD DATA INFILE '/Users/andyenkeboll/code/citibike-predictions/datasets/subway_status_2014.csv' 
INTO TABLE `mta_raw`
FIELDS TERMINATED BY '|'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, @timestamp, agency, subject, message)
SET sent_date = STR_TO_DATE(@timestamp , "%m/%d/%Y %h:%i:%s %p")
;

CREATE TABLE IF NOT EXISTS `socialdata`.`mta_status` (
  PRIMARY KEY (`id`),
) ENGINE=InnoDB DEFAULT CHARSET=utf8;