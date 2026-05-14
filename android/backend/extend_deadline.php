<?php
require 'db_config.php';

$id = $_POST['scholarship_id'] ?? '';
$new_date = $_POST['new_date'] ?? '';

if (empty($id) || empty($new_date)) {
    echo json_encode(["status"=>"error","message"=>"Missing data"]);
    exit;
}

$conn->query("
UPDATE scholarships 
SET application_end_date = '$new_date'
WHERE scholarship_id = $id
");

echo json_encode([
    "status"=>"success",
    "message"=>"Deadline extended"
]);
?>