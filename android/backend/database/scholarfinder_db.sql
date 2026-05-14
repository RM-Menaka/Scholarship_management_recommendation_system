-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 22, 2026 at 11:32 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `scholarfinder_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `colleges`
--

CREATE TABLE `colleges` (
  `college_id` int(11) NOT NULL,
  `college_name` varchar(150) DEFAULT NULL,
  `district` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `colleges`
--

INSERT INTO `colleges` (`college_id`, `college_name`, `district`) VALUES
(1, 'Anna University – CEG', 'Chennai'),
(2, 'PSG College of Technology', 'Coimbatore'),
(3, 'Thiagarajar College of Engineering', 'Madurai'),
(4, 'Government College of Technology', 'Coimbatore'),
(5, 'SSN College of Engineering', 'Chennai');

-- --------------------------------------------------------

--
-- Table structure for table `college_courses`
--

CREATE TABLE `college_courses` (
  `id` int(11) NOT NULL,
  `college_id` int(11) DEFAULT NULL,
  `course_name` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `college_courses`
--

INSERT INTO `college_courses` (`id`, `college_id`, `course_name`) VALUES
(1, 1, 'B.E Computer Science'),
(2, 1, 'B.E Mechanical'),
(3, 1, 'M.E Software Engineering'),
(4, 2, 'B.Tech Information Technology'),
(5, 2, 'B.E Electrical'),
(6, 3, 'B.E Civil Engineering'),
(7, 3, 'B.E Electronics'),
(8, 4, 'B.E Mechanical'),
(9, 4, 'B.E Production'),
(10, 5, 'B.Tech Artificial Intelligence'),
(11, 5, 'B.Tech Data Science');

-- --------------------------------------------------------

--
-- Table structure for table `scholarships`
--

CREATE TABLE `scholarships` (
  `scholarship_id` int(11) NOT NULL,
  `trust_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `category` enum('Merit','Need','Sports','Minority','Other') DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `total_slots` int(11) DEFAULT NULL,
  `education_level` enum('School','UG','PG','PhD') NOT NULL,
  `min_percentage` decimal(5,2) DEFAULT NULL,
  `max_income` decimal(10,2) DEFAULT NULL,
  `eligible_states` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`eligible_states`)),
  `gender_preference` enum('Any','Male','Female','Other') DEFAULT 'Any',
  `required_documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`required_documents`)),
  `application_start_date` date DEFAULT NULL,
  `application_end_date` date DEFAULT NULL,
  `status` enum('Open','Closed') DEFAULT 'Open',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `trust_profiles`
--

CREATE TABLE `trust_profiles` (
  `trust_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `trust_name` varchar(150) DEFAULT NULL,
  `trust_type` varchar(50) DEFAULT NULL,
  `registration_number` varchar(50) DEFAULT NULL,
  `trust_email` varchar(100) DEFAULT NULL,
  `trust_phone` varchar(15) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `district` varchar(50) DEFAULT NULL,
  `verification_status` enum('pending','approved','rejected') DEFAULT 'pending',
  `verified_by_admin` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `registration_certificate` varchar(255) DEFAULT NULL,
  `darpan_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trust_profiles`
--

INSERT INTO `trust_profiles` (`trust_id`, `user_id`, `trust_name`, `trust_type`, `registration_number`, `trust_email`, `trust_phone`, `address`, `state`, `district`, `verification_status`, `verified_by_admin`, `created_at`, `registration_certificate`, `darpan_id`) VALUES
(4, 33, 'ezhil', 'Society (TN Societies Act)', 'S/123/2019', 'ezhils0616@gmail.com', '86086785321', '13,NV ganesan street,periyapuliampatti, aruppukottai.', 'Tamil Nadu', 'Madurai', 'pending', NULL, '2026-03-14 06:26:07', NULL, NULL),
(7, 36, 'Hennah Trust', 'Society (TN Societies Act)', 'S/123', 'rmmenaka1905@gmail.com', '8608605321', 'no.8, Hast building, Thiruvanmiyur, Chennai', 'Tamil Nadu', 'Chennai', 'approved', 37, '2026-03-19 10:55:38', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `role` enum('student','trust_manager','admin') NOT NULL,
  `email_verified` tinyint(1) DEFAULT 0,
  `email_otp` varchar(6) DEFAULT NULL,
  `otp_expiry` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `status` enum('active','blocked') DEFAULT 'active',
  `profile_completed` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `email`, `password`, `phone`, `role`, `email_verified`, `email_otp`, `otp_expiry`, `created_at`, `status`, `profile_completed`) VALUES
(2, 'Test User', 'prav5812005@gmail.com', 'dummy', '9999999999', 'student', 0, '506453', '2025-12-17 10:20:50', '2025-12-17 14:40:19', 'active', 0),
(8, 'sastha', 'rm.menakaraja@gmail.com', '$2y$10$BwJ0ReNKh1Nzga/rh19VPuPwjf4be3s0emx7w1NwHzJXZNQu392Ua', '8608605321', 'student', 1, NULL, NULL, '2025-12-17 17:39:34', 'active', 0),
(12, 'Valli', 'shanmugavalli871@gmail.com', '$2y$10$TUNMvxi37yxN19Zk6zgwru4VdzGPmswGdorRD5sVAI/5Pe5kSVpJ2', '9390189971', 'student', 1, NULL, NULL, '2025-12-17 19:39:47', 'active', 0),
(33, 'Ezhil', 'ezhils0616@gmail.com', '$2y$10$IOzXi1ehSWcIEhEUL1ox/.2tkhRzyAaynqH/nvDcjGZF4LEN6Lopm', '6369642347', 'trust_manager', 1, NULL, NULL, '2026-03-14 09:41:34', 'active', 1),
(36, 'RM MENAKA', 'rmmenaka1905@gmail.com', '$2y$10$Y7irrjRaquFkAFOz5MCxKO8s0DmPwaSBh3U2mNMoBNria4S6hAEdm', '8608605321', 'trust_manager', 1, NULL, NULL, '2026-03-19 16:23:53', 'active', 1),
(37, '', 'admin@gmail.com', '$2y$10$QIv2/lXGDVaAsIcLd9ciqeSzVvqvu416.rFuNXZNSOdRu4qcyB5yK', NULL, 'admin', 1, NULL, NULL, '2026-03-19 23:29:08', 'active', 1),
(40, 'Boopathi', 'boopathisrithooyavan7@gmail.com', '$2y$10$IzHJ4PCH1L6QwrFB4FtW/.I7lSeOlRSInU98tMHCLXu51Jop3R42S', '8608605321', 'student', 1, NULL, NULL, '2026-04-22 14:54:10', 'active', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
--

CREATE TABLE `user_profiles` (
  `profile_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `category` varchar(20) DEFAULT NULL,
  `disability` varchar(5) DEFAULT NULL,
  `education_level` varchar(20) DEFAULT NULL,
  `course` varchar(50) DEFAULT NULL,
  `year_of_study` varchar(10) DEFAULT NULL,
  `academic_score` varchar(10) DEFAULT NULL,
  `income_range` varchar(20) DEFAULT NULL,
  `income_certificate` varchar(5) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `district` varchar(50) DEFAULT NULL,
  `area_type` varchar(10) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `college_name` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_profiles`
--

INSERT INTO `user_profiles` (`profile_id`, `user_id`, `gender`, `category`, `disability`, `education_level`, `course`, `year_of_study`, `academic_score`, `income_range`, `income_certificate`, `state`, `district`, `area_type`, `address`, `created_at`, `college_name`) VALUES
(9, 40, 'Male', 'General', 'No', 'UG', 'B.E Computer Science', '1', '8.5', 'Below 1L', 'Yes', 'Tamil Nadu', 'Chennai', 'Urban', 'No 3 ,NV street, periyapuliampatti,chennai', '2026-04-22 09:25:42', 'Anna University – CEG');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `colleges`
--
ALTER TABLE `colleges`
  ADD PRIMARY KEY (`college_id`);

--
-- Indexes for table `college_courses`
--
ALTER TABLE `college_courses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `college_id` (`college_id`);

--
-- Indexes for table `scholarships`
--
ALTER TABLE `scholarships`
  ADD PRIMARY KEY (`scholarship_id`),
  ADD KEY `trust_id` (`trust_id`),
  ADD KEY `education_level` (`education_level`),
  ADD KEY `status` (`status`),
  ADD KEY `application_end_date` (`application_end_date`);

--
-- Indexes for table `trust_profiles`
--
ALTER TABLE `trust_profiles`
  ADD PRIMARY KEY (`trust_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`profile_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `colleges`
--
ALTER TABLE `colleges`
  MODIFY `college_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `college_courses`
--
ALTER TABLE `college_courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `scholarships`
--
ALTER TABLE `scholarships`
  MODIFY `scholarship_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trust_profiles`
--
ALTER TABLE `trust_profiles`
  MODIFY `trust_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `profile_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `college_courses`
--
ALTER TABLE `college_courses`
  ADD CONSTRAINT `college_courses_ibfk_1` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`college_id`);

--
-- Constraints for table `scholarships`
--
ALTER TABLE `scholarships`
  ADD CONSTRAINT `scholarships_ibfk_1` FOREIGN KEY (`trust_id`) REFERENCES `trust_profiles` (`trust_id`);

--
-- Constraints for table `trust_profiles`
--
ALTER TABLE `trust_profiles`
  ADD CONSTRAINT `trust_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
