<?php
require 'db_config.php';
header("Content-Type: application/json");

// 🔥 prevent warnings
error_reporting(0);

// ================= APPLICATION STATUS =================
$appStatus = [];
$res1 = $conn->query("
SELECT status, COUNT(*) as count
FROM applications
GROUP BY status
");

while ($row = $res1->fetch_assoc()) {
    $appStatus[] = $row;
}

// ================= ACTIVE vs CLOSED =================
$res2 = $conn->query("
SELECT 
  SUM(CASE WHEN application_end_date >= CURDATE() THEN 1 ELSE 0 END) AS active,
  SUM(CASE WHEN application_end_date < CURDATE() THEN 1 ELSE 0 END) AS closed
FROM scholarships
");

$schStatus = $res2->fetch_assoc();

// ================= MONTHLY TREND =================
$monthly = [];
$res3 = $conn->query("
SELECT 
  DATE_FORMAT(applied_at, '%Y-%m') as month,
  COUNT(*) as total
FROM applications
GROUP BY month
ORDER BY month
");

while ($row = $res3->fetch_assoc()) {
    $monthly[] = $row;
}

// ================= RESPONSE =================
echo json_encode([
    "status" => "success",
    "application_status" => $appStatus,
    "scholarship_status" => $schStatus,
    "monthly_trend" => $monthly
]);

$conn->close();
?>