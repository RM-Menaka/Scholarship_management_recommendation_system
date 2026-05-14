<?php
require 'db_config.php';

header("Content-Type: application/json");

if (!isset($_POST['email'], $_POST['password'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Email and password are required"
    ]);
    exit;
}

$email = trim($_POST['email']);
$password = trim($_POST['password']);

// Fetch user
$stmt = $conn->prepare("
    SELECT user_id, password, role, email_verified, profile_completed, status
    FROM users
    WHERE email = ?
");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid email or password"
    ]);
    exit;
}

$user = $result->fetch_assoc();

// Check account status
if ($user['status'] !== 'active') {
    echo json_encode([
        "status" => "error",
        "message" => "Account is inactive"
    ]);
    exit;
}

// Check email verification
if ((int)$user['email_verified'] !== 1) {
    echo json_encode([
        "status" => "error",
        "message" => "Email not verified"
    ]);
    exit;
}

// Verify password
if (!password_verify($password, $user['password'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid email or password"
    ]);
    exit;
}

// ✅ SUCCESS
echo json_encode([
    "status" => "success",
    "user_id" => $user['user_id'],
    "role" => $user['role'],
    "profile_completed" => (int)$user['profile_completed']
]);
