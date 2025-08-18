-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema customer_segmentation
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema customer_segmentation
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `customer_segmentation` DEFAULT CHARACTER SET utf8 ;
USE `customer_segmentation` ;

-- -----------------------------------------------------
-- Table `customer_segmentation`.`customer_segmentation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customer_segmentation`.`customer_segmentation` (
  `id` INT NOT NULL,
  `age` INT NULL,
  `gender` VARCHAR(45) NULL,
  `income` INT NULL,
  `spending_score` INT NULL,
  `membership_years` INT NULL,
  `purchase_frequency` INT NULL,
  `preferred_category` VARCHAR(45) NULL,
  `last_purchase_amount` FLOAT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
