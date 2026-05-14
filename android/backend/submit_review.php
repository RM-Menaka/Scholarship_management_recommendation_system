<?php
require 'db_config.php';
header("Content-Type: application/json");

// ================= INPUT =================
$user_id = $_POST['user_id'] ?? '';
$scholarship_id = $_POST['scholarship_id'] ?? '';
$rating = $_POST['rating'] ?? '';
$comment = $_POST['comment'] ?? '';

// ================= VALIDATION =================
if (empty($user_id) || empty($scholarship_id) || empty($rating)) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing required fields"
    ]);
    exit;
}

// ================= CHECK APPLICATION STATUS =================
$check = $conn->query("
SELECT status 
FROM applications
WHERE user_id = $user_id 
AND scholarship_id = $scholarship_id
");

if (!$check || $check->num_rows == 0) {
    echo json_encode([
        "status" => "error",
        "message" => "You have not applied for this scholarship"
    ]);
    exit;
}

$row = $check->fetch_assoc();
$status = $row['status'];

// 🔥 ALLOW ONLY APPROVED / REJECTED
if ($status != "Approved" && $status != "Rejected") {
    echo json_encode([
        "status" => "error",
        "message" => "You can review only after decision"
    ]);
    exit;
}

// ================= PREVENT DUPLICATE REVIEW =================
$exists = $conn->query("
SELECT review_id 
FROM reviews
WHERE user_id = $user_id 
AND scholarship_id = $scholarship_id
");

if ($exists && $exists->num_rows > 0) {
    echo json_encode([
        "status" => "error",
        "message" => "You have already submitted a review"
    ]);
    exit;
}

// ================= GET TRUST ID =================
$getTrust = $conn->query("
SELECT trust_id 
FROM scholarships 
WHERE scholarship_id = $scholarship_id
");

if (!$getTrust || $getTrust->num_rows == 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Scholarship not found"
    ]);
    exit;
}

$trust = $getTrust->fetch_assoc();
$trust_id = $trust['trust_id'];

// ================= SAFE INPUT =================
$rating = intval($rating);
$comment = mysqli_real_escape_string($conn, $comment);

// ================= INSERT REVIEW =================
$insert = $conn->query("
INSERT INTO reviews (user_id, trust_id, scholarship_id, rating, comment)
VALUES ($user_id, $trust_id, $scholarship_id, $rating, '$comment')
");

if (!$insert) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to submit review",
        "debug" => $conn->error
    ]);
    exit;
}

// ================= SUCCESS =================
echo json_encode([
    "status" => "success",
    "message" => "Review submitted successfully"
]);

$conn->close();
?>