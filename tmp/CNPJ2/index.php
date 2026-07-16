<?php
// TEMPO DE EXEC SCRIPT
$start = microtime(true);

if ($_GET['key']!='Blue3000x.x'){
    echo "Erro permissão negada!";
    exit();
}

// Definindo
header('Content-Type: text/html; charset=UTF-8');

// Definindo Timezone
date_default_timezone_set('America/Sao_Paulo');

// Definindo
ini_set('session.referer_check', 'TRUE');


$CNPJ = testa_cnpj($_GET['cnpj']);