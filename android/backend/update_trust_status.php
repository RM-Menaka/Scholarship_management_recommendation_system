<?php
require 'db_config.php';
header("Content-Type: application/json");

// ================= INPUT =================
$user_id = $_POST['user_id'] ?? '';
$trust_id = $_POST['trust_id'] ?? '';
$status = $_POST['status'] ?? ''; // approved / rejected

// ================= VALIDATION =================
if (empty($user_id) || empty($trust_id) || empty($status)) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing parameters"
    ]);
    exit;
}

if (!in_array($status, ['approved', 'rejected'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid status"
    ]);
    exit;
}

// ================= ADMIN CHECK =================
$stmt = $conn->prepare("SELECT role FROM users WHERE user_id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$res = $stmt->get_result();
$user = $res->fetch_assoc();

if ($user['role'] !== 'admin') {
    echo json_encode([
        "status" => "error",
        "message" => "Unauthorized"
    ]);
    exit;
}

// ================= UPDATE STATUS =================
$update = $conn->prepare("
    UPDATE trust_profiles 
    SET verification_status = ?, verified_by_admin = ?
    WHERE trust_id = ?
");

$update->bind_param("sii", $status, $user_id, $trust_id);

if ($update->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Trust status updated"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Update failed"
    ]);
}

$update->close();
$conn->close();
?>