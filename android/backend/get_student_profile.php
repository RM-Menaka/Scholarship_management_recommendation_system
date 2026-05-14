<?php
require 'db_config.php';
header("Content-Type: application/json");

error_reporting(0);

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(["status"=>"error","message"=>"User ID required"]);
    exit;
}

$result = $conn->query("
SELECT * FROM user_profiles WHERE user_id = $user_id
");

if ($result->num_rows == 0) {
    echo json_encode(["status"=>"error","message"=>"Profile not found"]);
    exit;
}

$row = $result->fetch_assoc();

echo json_encode([
    "status"=>"success",
    "data"=>$row
]);

$conn->close();
?>