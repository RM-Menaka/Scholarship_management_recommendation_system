<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'db_config.php';
require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

header("Content-Type: application/json");

// Required fields
if (!isset($_POST['name'], $_POST['email'], $_POST['password'], $_POST['role'])) {
    echo json_encode(["status" => "error", "message" => "All fields are required"]);
    exit;
}

$name = trim($_POST['name']);
$email = trim($_POST['email']);
$password = password_hash($_POST['password'], PASSWORD_DEFAULT); // hash password
$role = trim($_POST['role']);
$phone = isset($_POST['phone']) ? trim($_POST['phone']) : '';

// Check if email already exists
$check = $conn->prepare("SELECT user_id, email_verified FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$result = $check->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    // If email exists but NOT verified → resend OTP
    if ($user['email_verified'] == 0) {

        $otp = rand(100000, 999999);
        $expiry = date("Y-m-d H:i:s", strtotime("+5 minutes"));

        $update = $conn->prepare(
            "UPDATE users SET email_otp = ?, otp_expiry = ? WHERE email = ?"
        );
        $update->bind_param("sss", $otp, $expiry, $email);
        $update->execute();

        // Send OTP again
        $mail = new PHPMailer(true);
        try {
            $mail->isSMTP();
            $mail->Host       = 'smtp.gmail.com';
            $mail->SMTPAuth   = true;
            $mail->Username   = 'rmmenaka1905@gmail.com';
            $mail->Password   = 'gmzg ieul pzgd njxq';
            $mail->SMTPSecure = 'tls';
            $mail->Port       = 587;

            $mail->setFrom('rmmenaka1905@gmail.com', 'ScholarFinder');
            $mail->addAddress($email);

            $mail->isHTML(true);
            $mail->Subject = 'ScholarFinder OTP (Resent)';
            $mail->Body    = "
                <h2>Email Verification</h2>
                <p>Your OTP is:</p>
                <h1>$otp</h1>
                <p>This OTP expires in 5 minutes.</p>
            ";

            $mail->send();

            echo json_encode([
                "status" => "otp_sent",
                "message" => "OTP resent successfully"
            ]);
            exit;

        } catch (Exception $e) {
            echo json_encode([
                "status" => "error",
                "message" => "Email failed"
            ]);
            exit;
        }
    }

    // If already verified → block
    echo json_encode([
        "status" => "error",
        "message" => "Email already registered and verified"
    ]);
    exit;
}


// Insert user with email_verified = 0
$insert = $conn->prepare("INSERT INTO users (name, email, password, phone, role, email_verified, status) VALUES (?, ?, ?, ?, ?, 0, 'active')");
$insert->bind_param("sssss", $name, $email, $password, $phone, $role);
$insert->execute();

// Generate OTP
$otp = rand(100000, 999999);
$expiry = date("Y-m-d H:i:s", strtotime("+5 minutes"));

// Save OTP
$update = $conn->prepare("UPDATE users SET email_otp = ?, otp_expiry = ? WHERE email = ?");
$update->bind_param("sss", $otp, $expiry, $email);
$update->execute();

// Send OTP email
$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'rmmenaka1905@gmail.com'; // 🔴 replace
    $mail->Password   = 'gmzg ieul pzgd njxq';    // 🔴 replace
    $mail->SMTPSecure = 'tls';
    $mail->Port       = 587;

    $mail->setFrom('rmmenaka1905@gmail.com', 'ScholarFinder');
    $mail->addAddress($email);

    $mail->isHTML(true);
    $mail->Subject = 'ScholarFinder Signup OTP';
    $mail->Body    = "
        <h2>Signup Verification</h2>
        <p>Your OTP is:</p>
        <h1>$otp</h1>
        <p>This OTP expires in 5 minutes.</p>
    ";

    $mail->send();

    echo json_encode(["status" => "success", "message" => "OTP sent. Verify your email to complete signup"]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Email failed", "error" => $mail->ErrorInfo]);
}
?>
