<?php
require 'db_config.php';
header("Content-Type: application/json");

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(["status"=>"error","message"=>"User ID required"]);
    exit;
}

// 🔥 FETCH APPLIED SCHOLARSHIPS
$result = $conn->query("
SELECT 
    a.application_id,
    a.status,
    a.applied_at,
    s.title,
    s.amount,
    s.scholarship_id,
    s.application_end_date,
    t.trust_name
FROM applications a
JOIN scholarships s ON a.scholarship_id = s.scholarship_id
JOIN trust_profiles t ON s.trust_id = t.trust_id
WHERE a.user_id = $user_id
ORDER BY a.applied_at DESC
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