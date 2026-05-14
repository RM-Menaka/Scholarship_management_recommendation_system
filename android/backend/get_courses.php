<?php
include "db_config.php";

$college_id = $_GET['college_id'];

$query = "SELECT course_name FROM college_courses WHERE college_id='$college_id'";
$result = $conn->query($query);

$data = [];
while ($row = $result->fetch_assoc()) {
  $data[] = $row['course_name'];
}

echo json_encode($data);
?>
