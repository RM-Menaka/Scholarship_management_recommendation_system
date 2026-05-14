<?php
require 'db_config.php';
header("Content-Type: application/json");

$user_id = $_GET['user_id'] ?? '';

if (!$user_id) {
    echo json_encode(["status"=>"error","message"=>"User ID required"]);
    exit;
}

// 🔥 GET TRUST ID
$getTrust = $conn->query("
SELECT trust_id FROM trust_profiles
WHERE user_id = $user_id
");

if ($getTrust->num_rows == 0) {
    echo json_encode(["status"=>"error","message"=>"Trust not found"]);
    exit;
}

$trust = $getTrust->fetch_assoc();
$trust_id = $trust['trust_id'];

// 🔥 FETCH REVIEWS
$result = $conn->query("
SELECT r.*, u.name, s.title
FROM reviews r
JOIN user_profiles u ON r.user_id = u.user_id
JOIN scholarships s ON r.scholarship_id = s.scholarship_id
WHERE r.trust_id = $trust_id
ORDER BY r.created_at DESC
");

$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "status"=>"success",
    "data"=>$data
]);

$conn->close();
?>