<?php
$host = "localhost";  // Cambia si estás en un hosting
$user = "root";       // Usuario de MySQL
$password = "";       // Contraseña de MySQL
$database = "flutter_auth";

$conn = new mysqli($host, $user, $password, $database);
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida"]));
}
?>
