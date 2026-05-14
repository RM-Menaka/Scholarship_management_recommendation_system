<?php
include "db_config.php";

$district = $_GET['district'];

$query = "SELECT college_id, college_name FROM colleges WHERE district='$district'";
$result = $conn->query($query);

$data = [];
while ($row = $result->fetch_assoc()) {
  $data[] = $row;
}

echo json_encode($data);
?>
