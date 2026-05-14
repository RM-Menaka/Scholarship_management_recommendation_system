<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

function sendOTP($email, $otp) {
    $mail = new PHPMailer(true);

    try {
        $mail->isSMTP();
        $mail->Host       = 'smtp.gmail.com';
        $mail->SMTPAuth   = true;

        // 🔴 USE YOUR GMAIL
        $mail->Username   = 'yourgmail@gmail.com';
        $mail->Password   = 'YOUR_APP_PASSWORD';

        $mail->SMTPSecure = 'tls';
        $mail->Port       = 587;

        $mail->setFrom('yourgmail@gmail.com', 'ScholarFinder');
        $mail->addAddress($email);

        $mail->isHTML(true);
        $mail->Subject = 'ScholarFinder OTP Verification';
        $mail->Body    = "<h3>Your OTP is: <b>$otp</b></h3>
                          <p>Valid for 10 minutes.</p>";

        $mail->send();
        return true;
    } catch (Exception $e) {
        return false;
    }
}
?>
