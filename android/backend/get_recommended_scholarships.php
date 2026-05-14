<?php
require 'db_config.php';
header("Content-Type: application/json");

// 🔥 VERY IMPORTANT (prevents warning breaking JSON)
error_reporting(0);

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(["status" => "error", "message" => "User ID required"]);
    exit;
}

// ================= USER PROFILE =================
$profile = $conn->query("
    SELECT * FROM user_profiles WHERE user_id = $user_id
")->fetch_assoc();

if (!$profile) {
    echo json_encode(["status" => "error", "message" => "Profile not found"]);
    exit;
}

// 🔥 CONVERT STUDENT DATA

// 📊 academic_score → percentage
$student_percentage = 0;

if (!empty($profile['academic_score'])) {
    $student_percentage = floatval($profile['academic_score']);

    // If CGPA (like 8.5), convert → 85
    if ($student_percentage <= 10) {
        $student_percentage = $student_percentage * 10;
    }
}

// 💰 income_range → number
$student_income = 0;

if (!empty($profile['income_range'])) {

    $income = strtolower($profile['income_range']);

    if (strpos($income, '1l') !== false) {
        $student_income = 100000;
    } elseif (strpos($income, '2l') !== false) {
        $student_income = 200000;
    } elseif (strpos($income, '3l') !== false) {
        $student_income = 300000;
    } else {
        $student_income = 500000; // fallback
    }
}

// ================= SCHOLARSHIPS =================
$query = "
SELECT 
    s.*,
    t.trust_name,
    COALESCE(t.trust_email, '') AS trust_email,
    a.status AS application_status
FROM scholarships s

LEFT JOIN trust_profiles t 
ON CAST(s.trust_id AS UNSIGNED) = CAST(t.trust_id AS UNSIGNED)

LEFT JOIN applications a 
ON s.scholarship_id = a.scholarship_id 
AND a.user_id = $user_id

WHERE s.status = 'Open'
";

$result = $conn->query($query);

$final = [];

while ($sch = $result->fetch_assoc()) {
    // 🎓 STRICT EDUCATION FILTER
if (!empty($sch['education_level']) &&
    $profile['education_level'] != $sch['education_level']) {
    continue; // skip this scholarship
}

    $score = 0;
    $reasons = [];

    // 🎓 EDUCATION
    if (!empty($sch['education_level']) &&
        $profile['education_level'] == $sch['education_level']) {
        $score += 30;
        $reasons[] = "Matches your education";
    }

    // 📊 PERCENTAGE
    if (!empty($sch['min_percentage']) &&
        $student_percentage >= $sch['min_percentage']) {
        $score += 20;
        $reasons[] = "Meets percentage criteria";
    }

    // 💰 INCOME
    if (!empty($sch['max_income']) &&
        $student_income <= $sch['max_income']) {
        $score += 20;
        $reasons[] = "Within income limit";
    }

    // 📍 STATE (SAFE JSON + TEXT)
    if (!empty($sch['eligible_states'])) {

        $statesRaw = $sch['eligible_states'];
        $states = json_decode($statesRaw, true);

        if (is_array($states)) {
            if (in_array($profile['state'], $states)) {
                $score += 10;
                $reasons[] = "Eligible in your state";
            }
        } else {
            if (stripos($statesRaw, $profile['state']) !== false) {
                $score += 10;
                $reasons[] = "Eligible in your state";
            }
        }
    }

    // 🚻 GENDER
    if (!empty($sch['gender_preference'])) {
        if ($sch['gender_preference'] == "Any" ||
            $sch['gender_preference'] == $profile['gender']) {
            $score += 10;
            $reasons[] = "Gender eligible";
        }
    }

    // 🧠 INTEREST MATCH
    if (!empty($profile['interests'])) {
        $text = strtolower($sch['title'] . " " . $sch['description']);
        $keywords = explode(",", strtolower($profile['interests']));

        foreach ($keywords as $word) {
            $word = trim($word);
            if (!empty($word) && strpos($text, $word) !== false) {
                $score += 5;
                $reasons[] = "Matches your interests";
                break;
            }
        }
    }

    // 🔥 FILTER
    if ($score >= 30) {
        $sch['match_score'] = $score;
        $sch['reason'] = implode(", ", $reasons);
        $final[] = $sch;
    }
}

// 🔥 SORT
usort($final, function ($a, $b) {
    return $b['match_score'] - $a['match_score'];
});

echo json_encode([
    "status" => "success",
    "data" => $final
]);

$conn->close();
?>