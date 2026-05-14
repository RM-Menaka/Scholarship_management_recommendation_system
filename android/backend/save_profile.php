<?php
header('Content-Type: application/json');
require_once "db_config.php";

// 🔥 SHOW ERRORS (REMOVE IN PRODUCTION)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// ================= INPUT =================
$user_id         = $_POST['user_id'] ?? '';
$name            = trim($_POST['name'] ?? '');
$gender          = $_POST['gender'] ?? '';
$category        = $_POST['category'] ?? '';
$disability      = $_POST['disability'] ?? '';
$education_level = $_POST['education_level'] ?? '';
$course          = $_POST['course'] ?? '';
$year_of_study   = $_POST['year_of_study'] ?? '';
$academic_score  = $_POST['academic_score'] ?? '';
$income_range    = $_POST['income_range'] ?? '';

// ================= VALIDATION =================
$missing = [];

if (empty($user_id))         $missing[] = "user_id";
if (empty($name))            $missing[] = "name";
if (empty($gender))          $missing[] = "gender";
if (empty($category))        $missing[] = "category";
if (empty($education_level)) $missing[] = "education_level";
if (empty($year_of_study))   $missing[] = "year_of_study";
if (empty($academic_score))  $missing[] = "academic_score";
if (empty($income_range))    $missing[] = "income_range";

if (!empty($missing)) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing fields: " . implode(", ", $missing)
    ]);
    exit;
}

// ================= FILE UPLOAD =================
$certificatePath = "";

if (isset($_FILES['income_certificate']) && $_FILES['income_certificate']['error'] == 0) {

    $uploadDir = "uploads/";

    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    // 🔥 VALIDATE FILE TYPE
    $allowedTypes = ['pdf', 'jpg', 'jpeg', 'png'];
    $fileExt = strtolower(pathinfo($_FILES['income_certificate']['name'], PATHINFO_EXTENSION));

    if (!in_array($fileExt, $allowedTypes)) {
        echo json_encode([
            "status" => "error",
            "message" => "Only PDF/JPG/PNG allowed"
        ]);
        exit;
    }

    // 🔥 UNIQUE FILE NAME
    $filename = time() . "_" . basename($_FILES['income_certificate']['name']);
    $targetFile = $uploadDir . $filename;

    if (move_uploaded_file($_FILES['income_certificate']['tmp_name'], $targetFile)) {
        $certificatePath = $filename;
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "File upload failed"
        ]);
        exit;
    }
}

// ================= INSERT / UPDATE =================
$stmt = $conn->prepare("
INSERT INTO user_profiles
(user_id, name, gender, category, disability, education_level,
 course, year_of_study, academic_score, income_range, income_certificate)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)

ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    gender = VALUES(gender),
    category = VALUES(category),
    disability = VALUES(disability),
    education_level = VALUES(education_level),
    course = VALUES(course),
    year_of_study = VALUES(year_of_study),
    academic_score = VALUES(academic_score),
    income_range = VALUES(income_range),
    income_certificate = IF(VALUES(income_certificate) != '', VALUES(income_certificate), income_certificate)
");

$stmt->bind_param(
    "issssssssss",
    $user_id,
    $name,
    $gender,
    $category,
    $disability,
    $education_level,
    $course,
    $year_of_study,
    $academic_score,
    $income_range,
    $certificatePath
);

// ================= EXECUTE =================
if ($stmt->execute()) {

    $conn->query("UPDATE users SET profile_completed = 1 WHERE user_id = '$user_id'");

    echo json_encode([
        "status" => "success",
        "message" => "Profile saved successfully"
    ]);

} else {
    echo json_encode([
        "status" => "error",
        "message" => "Database error",
        "debug" => $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>