<?php
header('Content-Type: application/json');
require_once "db_config.php";

// ================= INPUT =================
$user_id = $_POST['trust_id'] ?? '';

$title = trim($_POST['title'] ?? '');
$description = trim($_POST['description'] ?? '');
$category = $_POST['category'] ?? '';

$amount = $_POST['amount'] ?? 0;
$total_slots = $_POST['total_slots'] ?? 0;

$education_level = $_POST['education_level'] ?? '';

$min_percentage = $_POST['min_percentage'] ?? 0;
$max_income = $_POST['max_income'] ?? 0;

$gender_preference = $_POST['gender_preference'] ?? 'Any';

// 🔥 KEEP DEFAULT (IMPORTANT)
$eligible_states = '["All"]';

// 🔥 REMOVE COMPLEXITY (NO JSON ISSUE)
$required_documents = $_POST['required_documents'] ?? '[]';
$required_fields = '[]'; // ❌ force empty (no JSON problems)

$application_start_date = $_POST['application_start_date'] ?? date("Y-m-d");
$application_end_date = $_POST['application_end_date'] ?? date("Y-m-d");

// ================= VALIDATION =================
if (
    empty($user_id) ||
    empty($title) ||
    empty($description) ||
    empty($education_level)
) {
    echo json_encode([
        "status" => "error",
        "message" => "Required fields missing"
    ]);
    exit;
}

// ================= GET TRUST =================
$getTrust = $conn->prepare("
    SELECT trust_id, verification_status 
    FROM trust_profiles 
    WHERE user_id = ?
");

$getTrust->bind_param("i", $user_id);
$getTrust->execute();
$result = $getTrust->get_result();

if (!$row = $result->fetch_assoc()) {
    echo json_encode([
        "status" => "error",
        "message" => "Trust profile not found"
    ]);
    exit;
}

// 🔒 CHECK APPROVAL
if ($row['verification_status'] != 'approved') {
    echo json_encode([
        "status" => "error",
        "message" => "Trust not approved"
    ]);
    exit;
}

$trust_id = $row['trust_id'];

// ================= INSERT =================
$stmt = $conn->prepare("
INSERT INTO scholarships (
    trust_id, title, description, category,
    amount, total_slots,
    education_level, min_percentage, max_income,
    eligible_states, gender_preference,
    required_documents, required_fields,
    application_start_date, application_end_date,
    status
)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Open')
");

if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => $conn->error
    ]);
    exit;
}

// ================= BIND =================
$stmt->bind_param(
    "isssdiisdssssss",
    $trust_id,
    $title,
    $description,
    $category,
    $amount,
    $total_slots,
    $education_level,
    $min_percentage,
    $max_income,
    $eligible_states,
    $gender_preference,
    $required_documents,
    $required_fields,
    $application_start_date,
    $application_end_date
);

// ================= EXECUTE =================
if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Scholarship posted successfully"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => $stmt->error
    ]);
}

// ================= CLOSE =================
$stmt->close();
$conn->close();
?>