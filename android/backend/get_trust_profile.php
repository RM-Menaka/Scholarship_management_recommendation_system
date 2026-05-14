<?php
header('Content-Type: application/json');
require_once "db_config.php";

// ================= GET USER ID =================
$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode([
        "status" => "error",
        "message" => "User ID required"
    ]);
    exit;
}

// ================= FETCH DATA =================
$stmt = $conn->prepare("
    SELECT 
        trust_name,
        trust_email,
        trust_phone,
        state,
        district,
        trust_type,
        verification_status
    FROM trust_profiles 
    WHERE user_id = ?
");

$stmt->bind_param("i", $user_id);
$stmt->execute();

$result = $stmt->get_result();

// ================= RESPONSE =================
if ($row = $result->fetch_assoc()) {
    echo json_encode([
        "status" => "success",
        "data" => $row
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Profile not found"
    ]);
}

$stmt->close();
$conn->close();
?>