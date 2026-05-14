<?php
require 'db_config.php';
header("Content-Type: application/json");

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode([
        "status" => "error",
        "message" => "User ID required"
    ]);
    exit;
}

// ================= GET TRUST_ID =================
$getTrust = $conn->query("
    SELECT trust_id 
    FROM trust_profiles 
    WHERE user_id = $user_id
");

if ($getTrust->num_rows == 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Trust not found"
    ]);
    exit;
}

$trust = $getTrust->fetch_assoc();
$trust_id = $trust['trust_id'];

// ================= FETCH WITH APPLICANT STATS =================
$query = "
SELECT 
    s.*,

    COUNT(a.application_id) AS applicants_count,

    COALESCE(SUM(CASE 
        WHEN a.status = 'Approved' THEN 1 
        ELSE 0 
    END), 0) AS approved_count,

    COALESCE(SUM(CASE 
        WHEN a.status = 'Pending' THEN 1 
        ELSE 0 
    END), 0) AS pending_count

FROM scholarships s

LEFT JOIN applications a 
ON s.scholarship_id = a.scholarship_id

WHERE s.trust_id = $trust_id

GROUP BY s.scholarship_id

ORDER BY s.created_at DESC
";

$result = $conn->query($query);

$data = [];
$active = 0;
$closed = 0;
$totalApplicants = 0; // 🔥 NEW

$today = date("Y-m-d");

while ($row = $result->fetch_assoc()) {

    // ================= STATUS LOGIC =================
    if (!empty($row['application_end_date'])) {
        if ($row['application_end_date'] >= $today) {
            $row['status_live'] = "active";
            $active++;
        } else {
            $row['status_live'] = "closed";
            $closed++;
        }
    } else {
        $row['status_live'] = "unknown";
    }

    // ================= SAFE DEFAULTS =================
    $row['applicants_count'] = (int)($row['applicants_count'] ?? 0);
    $row['approved_count'] = (int)($row['approved_count'] ?? 0);
    $row['pending_count'] = (int)($row['pending_count'] ?? 0);

    // 🔥 TOTAL APPLICANTS COUNT
    $totalApplicants += $row['applicants_count'];

    $data[] = $row;
}

// ================= TOTAL =================
$total = count($data);

// ================= FINAL RESPONSE =================
echo json_encode([
    "status" => "success",

    "data" => $data,

    "stats" => [
        "active" => $active,
        "closed" => $closed,
        "total" => $total,
        "applicants" => $totalApplicants // 🔥 NEW
    ]
]);

$conn->close();
?>