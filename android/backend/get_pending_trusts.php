<?php
require 'db_config.php';
header("Content-Type: application/json");

// 🔴 SHOW ERRORS (for debugging)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// ================= INPUT =================
$user_id = $_GET['user_id'] ?? '';

// ================= CHECK EMPTY =================
if (empty($user_id)) {
    echo json_encode([
        "status" => "error",
        "message" => "user_id missing"
    ]);
    exit;
}

// ================= CHECK ADMIN =================
$stmt = $conn->prepare("SELECT role FROM users WHERE user_id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$res = $stmt->get_result();

$user = $res->fetch_assoc();

// ✅ FIX: check null
if (!$user) {
    echo json_encode([
        "status" => "error",
        "message" => "User not found"
    ]);
    exit;
}

// ✅ FIX: check role
if ($user['role'] !== 'admin') {
    echo json_encode([
        "status" => "error",
        "message" => "Unauthorized"
    ]);
    exit;
}

// ================= FETCH TRUSTS =================
$query = "
SELECT trust_id, trust_name, trust_email, verification_status, registration_certificate
FROM trust_profiles
WHERE verification_status = 'pending'
";

$result = $conn->query($query);

$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

// ================= RESPONSE =================
echo json_encode([
    "status" => "success",
    "data" => $data
]);

$conn->close();
?>