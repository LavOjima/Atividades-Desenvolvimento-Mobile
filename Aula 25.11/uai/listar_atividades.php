<?php
require "conexao.php";

$ano = intval($_GET["ano"] ?? date("Y"));
$mes = intval($_GET["mes"] ?? date("m"));

$stmt = $conn->prepare("
    SELECT id, dia, descricao
    FROM atividades
    WHERE YEAR(dia) = ? AND MONTH(dia) = ?
    ORDER BY dia DESC, id DESC
");
$stmt->bind_param("ii", $ano, $mes);
$stmt->execute();
$res = $stmt->get_result();

$lista = [];
while ($row = $res->fetch_assoc()) {
    $lista[] = $row;
}

echo json_encode($lista);

$stmt->close();
$conn->close();