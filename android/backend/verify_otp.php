<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'db_config.php';
header("Content-Type: application/json");

if (!isset($_POST['email']) || !isset($_POST['otp'])) {
    echo json_encode(["status" => "error", "message" => "Email and OTP are required"]);
    exit;
}

$email = trim($_POST['email']);
$otp = trim($_POST['otp']);

// Check if user exists
$check = $conn->prepare("SELECT user_id, otp_expiry FROM users WHERE email = ? AND email_otp = ?");
$check->bind_param("ss", $email, $otp);
$check->execute();
$result = $check->get_result();

if ($result->num_rows == 0) {
    echo json_encode(["status" => "error", "message" => "Invalid OTP or email"]);
    exit;
}

$user = $result->fetch_assoc();
$current_time = date("Y-m-d H:i:s");

if ($current_time > $user['otp_expiry']) {
    echo json_encode(["status" => "error", "message" => "OTP expired"]);
    exit;
}

// OTP valid → verify email
$update = $conn->prepare("UPDATE users SET email_verified = 1, email_otp = NULL, otp_expiry = NULL WHERE email = ?");
$update->bind_param("s", $email);
$update->execute();

echo json_encode(["status" => "success", "message" => "Email verified successfully"]);
?>
