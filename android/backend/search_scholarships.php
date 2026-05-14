<?php
require 'db_config.php';
header("Content-Type: application/json");

$search = $_GET['search'] ?? '';

// 🔥 BASE QUERY
$query = "
SELECT s.*, t.trust_name
FROM scholarships s
JOIN trust_profiles t ON s.trust_id = t.trust_id
WHERE s.status = 'Open'
";

// 🔍 APPLY SEARCH FILTER
if (!empty($search)) {
    $search = $conn->real_escape_string($search);

    $query .= " AND (
        s.title LIKE '%$search%' OR
        s.description LIKE '%$search%' OR
        s.category LIKE '%$search%' OR
        t.trust_name LIKE '%$search%'
    )";
}

$query .= " ORDER BY s.created_at DESC";

$result = $conn->query($query);

$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "status" => "success",
    "data" => $data
]);

$conn->close();
?>