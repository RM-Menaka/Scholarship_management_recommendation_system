<?php
require 'db_config.php';
header("Content-Type: application/json");

$user_id = $_GET['user_id'];

$result = $conn->query("
SELECT * FROM notifications
WHERE user_id = $user_id
ORDER BY created_at DESC
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