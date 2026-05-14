<?php
require 'db_config.php';
header("Content-Type: application/json");

$scholarship_id = $_GET['scholarship_id'];

$result = $conn->query("
SELECT 
    a.*,
    u.name,
    u.email,
    u.phone,
    p.education_level,
    p.academic_score,
    p.income_range,
    p.state

FROM applications a
JOIN users u ON a.user_id = u.user_id
LEFT JOIN user_profiles p ON u.user_id = p.user_id

WHERE a.scholarship_id = $scholarship_id
");

$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "status" => "success",
    "data" => $data
]);
?>