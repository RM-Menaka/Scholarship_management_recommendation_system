<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'db_config.php';
require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

header("Content-Type: application/json");

$email = $_POST['email'] ?? $_GET['email'] ?? '';

$email = trim($email);

if (empty($email)) {
    echo json_encode([
        "status" => "error",
        "message" => "Email is required"
    ]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid email format"
    ]);
    exit;
}

// Generate OTP
$otp = rand(100000, 999999);
$expiry = date("Y-m-d H:i:s", strtotime("+5 minutes"));

// Check if user exists
$check = $conn->prepare("SELECT user_id FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$result = $check->get_result();

if ($result->num_rows == 0) {
    echo json_encode(["status" => "error", "message" => "Email not registered"]);
    exit;
}

// Save OTP
$update = $conn->prepare(
    "UPDATE users SET email_otp = ?, otp_expiry = ? WHERE email = ?"
);
$update->bind_param("sss", $otp, $expiry, $email);
$update->execute();

// Send Email
$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'rmmenaka1905@gmail.com';     // 🔴 replace
    $mail->Password   = 'gmzg ieul pzgd njxq'; // 🔴 replace
    $mail->SMTPSecure = 'tls';
    $mail->Port       = 587;

    $mail->setFrom('rmmenaka1905@gmail.com', 'ScholarFinder');
    $mail->addAddress($email);

    $mail->isHTML(true);
    $mail->Subject = 'Your ScholarFinder OTP';
    $mail->Body    = "
        <h2>Email Verification</h2>
        <p>Your OTP is:</p>
        <h1>$otp</h1>
        <p>This OTP expires in 5 minutes.</p>
    ";

    $mail->send();

    echo json_encode(["status" => "success", "message" => "OTP sent to email"]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Email failed",
        "error" => $mail->ErrorInfo
    ]);
}
