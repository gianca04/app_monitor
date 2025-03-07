<?php
header("Content-Type: application/json");
include "config/db.php";

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data["name"]) && isset($data["email"]) && isset($data["password"])) {
    $name = $data["name"];
    $email = $data["email"];
    $password = password_hash($data["password"], PASSWORD_DEFAULT);

    $query = $conn->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
    $query->bind_param("sss", $name, $email, $password);

    if ($query->execute()) {
        echo json_encode(["status" => "success", "message" => "Usuario registrado"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error al registrar"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Faltan datos"]);
}
?>
