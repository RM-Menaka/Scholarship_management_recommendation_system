<?php
require 'db_config.php';
header("Content-Type: application/json");

$user_id = $_POST['user_id'] ?? '';

if (!$user_id) {
    echo json_encode(["status"=>"error","message"=>"User ID required"]);
    exit;
}

// 🔥 ESCAPE ALL INPUTS
function safe($conn, $key) {
    return mysqli_real_escape_string($conn, $_POST[$key] ?? '');
}

// 🔥 HANDLE FILE FIRST
$certificate = "";

if (isset($_FILES['income_certificate']) && $_FILES['income_certificate']['error'] == 0) {

    $dir = "uploads/";
    if (!is_dir($dir)) mkdir($dir, 0777, true);

    $filename = time() . "_" . $_FILES['income_certificate']['name'];

    if (move_uploaded_file($_FILES['income_certificate']['tmp_name'], $dir . $filename)) {
        $certificate = $filename;
    }
}

// 🔥 SAFE VALUES
$name = safe($conn, 'name');
$gender = safe($conn, 'gender');
$category = safe($conn, 'category');
$disability = safe($conn, 'disability');
$edu = safe($conn, 'education_level');
$course = safe($conn, 'course');
$year = safe($conn, 'year_of_study');
$score = safe($conn, 'academic_score');
$income = safe($conn, 'income_range');
$state = safe($conn, 'state');

$college = safe($conn, 'college_name');

// 🔥 BUILD QUERY
$query = "
UPDATE user_profiles SET
    name = '$name',
    gender = '$gender',
    category = '$category',
    disability = '$disability',
    education_level = '$edu',
    course = '$course',
    year_of_study = '$year',
    academic_score = '$score',
    income_range = '$income',
    state = '$state',
    
    college_name = '$college'
";

// 🔥 ADD FILE ONLY IF EXISTS
if ($certificate != "") {
    $query .= ", income_certificate = '$certificate'";
}

$query .= " WHERE user_id = $user_id";

// 🔥 EXECUTE WITH ERROR CHECK
if ($conn->query($query)) {
    echo json_encode([
        "status"=>"success",
        "message"=>"Profile updated successfully"
    ]);
} else {
    echo json_encode([
        "status"=>"error",
        "message"=>$conn->error // 🔥 THIS SHOWS REAL ERROR
    ]);
}

$conn->close();
?>