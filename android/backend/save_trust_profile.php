<?php
header('Content-Type: application/json');
require_once "db_config.php";

$user_id             = $_POST['user_id'] ?? '';
$trust_name          = $_POST['trust_name'] ?? '';
$trust_type          = $_POST['trust_type'] ?? '';
$registration_number = $_POST['registration_number'] ?? '';
$trust_email         = $_POST['trust_email'] ?? '';
$trust_phone         = $_POST['trust_phone'] ?? '';
$address             = $_POST['address'] ?? '';
$state               = $_POST['state'] ?? '';
$district            = $_POST['district'] ?? '';

if (
    empty($user_id) || empty($trust_name) || empty($trust_type) ||
    empty($registration_number) || empty($trust_email) ||
    empty($trust_phone) || empty($address) ||
    empty($state) || empty($district)
) {
    echo json_encode(["status" => "error", "message" => "All fields required"]);
    exit;
}

$stmt = $conn->prepare(
    "INSERT INTO trust_profiles 
    (user_id, trust_name, trust_type, registration_number, trust_email, trust_phone, address, state, district, verification_status)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')"
);

if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => "Prepare failed",
        "debug" => $conn->error
    ]);
    exit;
}

$stmt->bind_param(
    "issssssss",
    $user_id,
    $trust_name,
    $trust_type,
    $registration_number,
    $trust_email,
    $trust_phone,
    $address,
    $state,
    $district
);

if ($stmt->execute()) {

    $update = $conn->prepare(
        "UPDATE users SET profile_completed = 1 WHERE user_id = ?"
    );
    $update->bind_param("i", $user_id);
    $update->execute();

    echo json_encode(["status" => "success"]);

} else {
    echo json_encode([
        "status" => "error",
        "message" => "Database error",
        "debug" => $stmt->error
    ]);
}

$stmt->close();
$conn->close();
