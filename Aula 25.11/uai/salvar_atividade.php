<?php
require "conexao.php";

$dia       = trim($_POST["dia"] ?? "");
$atividade = trim($_POST["atividade"] ?? "");

if ($dia === "" || $atividade === "") {
    echo json_encode(["sucesso" => false, "mensagem" => "Informe o dia e a atividade."]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO atividades (dia, descricao) VALUES (?, ?)");
$stmt->bind_param("ss", $dia, $atividade);

if ($stmt->execute()) {
    echo json_encode(["sucesso" => true, "mensagem" => "Atividade salva.", "id" => $stmt->insert_id]);
} else {
    echo json_encode(["sucesso" => false, "mensagem" => "Erro ao salvar atividade."]);
}

$stmt->close();
$conn->close();