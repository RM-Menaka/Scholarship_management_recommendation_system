<?php
require 'db_config.php';
header("Content-Type: application/json");

// ================= INPUT =================
$user_id = $_POST['user_id'] ?? '';
$scholarship_id = $_POST['scholarship_id'] ?? '';
$extra_data = $_POST['extra_data'] ?? null; // 🔥 NEW

if (empty($user_id) || empty($scholarship_id)) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing data"
    ]);
    exit;
}

// ================= CHECK DEADLINE =================
$checkDeadline = $conn->query("
    SELECT application_end_date 
    FROM scholarships 
    WHERE scholarship_id = $scholarship_id
")->fetch_assoc();

if (!$checkDeadline) {
    echo json_encode([
        "status" => "error",
        "message" => "Scholarship not found"
    ]);
    exit;
}

$today = date("Y-m-d");

if ($checkDeadline['application_end_date'] < $today) {
    echo json_encode([
        "status" => "error",
        "message" => "Deadline has passed"
    ]);
    exit;
}

// ================= CHECK DUPLICATE =================
$check = $conn->query("
    SELECT * FROM applications 
    WHERE user_id = $user_id 
    AND scholarship_id = $scholarship_id
");

if ($check->num_rows > 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Already applied"
    ]);
    exit;
}

// ================= FILE UPLOAD =================
$uploadDir = "uploads/";

if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$docs = [];

foreach ($_FILES as $key => $file) {

    if ($file['error'] == 0) {

        $filename = time() . "_" . basename($file['name']);
        $targetFile = $uploadDir . $filename;

        if (move_uploaded_file($file['tmp_name'], $targetFile)) {
            $docs[$key] = $filename;
        }
    }
}

// 🔥 CONVERT TO JSON
$documents_json = !empty($docs) ? json_encode($docs) : null;

// ================= INSERT =================
$stmt = $conn->prepare("
    INSERT INTO applications 
    (user_id, scholarship_id, extra_data, documents, status)
    VALUES (?, ?, ?, ?, 'Pending')
");

if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => $conn->error
    ]);
    exit;
}

$stmt->bind_param(
    "iiss",
    $user_id,
    $scholarship_id,
    $extra_data,
    $documents_json
);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Application submitted successfully"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>