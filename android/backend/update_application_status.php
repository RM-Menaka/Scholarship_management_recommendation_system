<?php
require 'db_config.php';
header("Content-Type: application/json");
error_reporting(0);

$application_id = $_POST['application_id'] ?? '';
$status = $_POST['status'] ?? '';

if (empty($application_id) || empty($status)) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing data"
    ]);
    exit;
}

// ================= GET CURRENT STATUS =================
$current = $conn->query("
SELECT status FROM applications
WHERE application_id = $application_id
");

if (!$current || $current->num_rows == 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Application not found"
    ]);
    exit;
}

$current_status = $current->fetch_assoc()['status'];

// ================= PREVENT SAME STATUS =================
if ($current_status == $status) {
    echo json_encode([
        "status" => "success",
        "message" => "Status already updated"
    ]);
    exit;
}

// ================= RULE =================
if ($current_status == 'Approved' && $status == 'Rejected') {
    echo json_encode([
        "status" => "error",
        "message" => "Cannot reject an approved application"
    ]);
    exit;
}

// ================= UPDATE =================
$update = $conn->query("
UPDATE applications
SET status = '$status'
WHERE application_id = $application_id
");

if (!$update) {
    echo json_encode([
        "status" => "error",
        "message" => "Status update failed",
        "debug" => $conn->error
    ]);
    exit;
}

// ================= GET USER =================
$get = $conn->query("
SELECT a.user_id, s.title
FROM applications a
JOIN scholarships s 
ON a.scholarship_id = s.scholarship_id
WHERE a.application_id = $application_id
");

if ($get && $row = $get->fetch_assoc()) {

    $user_id = $row['user_id'];
    $title = $row['title'];

    // ================= MESSAGE =================
    if ($status == "Approved") {
        $message = "Your application for '$title' has been APPROVED 🎉";
    } elseif ($status == "Rejected") {
        $message = "Your application for '$title' has been REJECTED";
    } elseif ($status == "Revoked") {
        $message = "Your approval for '$title' has been REVOKED";
    } else {
        $message = "Your application status for '$title' has been updated";
    }

    // ================= INSERT NOTIFICATION =================
    // ================= SAFE MESSAGE =================
$message = mysqli_real_escape_string($conn, $message);

// ================= INSERT NOTIFICATION =================
$insert = $conn->query("
INSERT INTO notifications (user_id, title, message, is_read)
VALUES ($user_id, 'Application Update', '$message', 0)
");

if (!$insert) {
    echo json_encode([
        "status" => "error",
        "message" => "Notification insert failed",
        "debug" => $conn->error
    ]);
    exit;
}

    
    }


// ================= RESPONSE =================
echo json_encode([
    "status" => "success",
    "message" => "Status updated successfully"
]);

$conn->close();
?>