<?php
require 'db_config.php';

$id = $_POST['scholarship_id'] ?? '';

if (empty($id)) {
    echo json_encode(["status"=>"error","message"=>"ID required"]);
    exit;
}

$conn->query("DELETE FROM scholarships WHERE scholarship_id = $id");

echo json_encode([
    "status"=>"success",
    "message"=>"Scholarship deleted"
]);
?>