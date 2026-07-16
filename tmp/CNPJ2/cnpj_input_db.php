<?php

/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Scripting/EmptyPHP.php to edit this template
 */


/*
 * CONEXÃO COM O BANCO DE DADOS
 */
$dbase = "CNPJ";    // database name
$server = "100.64.66.211";       // host
$user = "cnpjUser";           // usuario
$password = "q4j45B4c9NU2rL9qxLMS7aD";  // password
$dbchar = "utf8";                // charset
try {
    $pdo = new PDO("mysql:host=$server;dbname=$dbase", $user, $password, array(PDO::ERRMODE_WARNING));
} catch (PDOException $error) {
    $errorSQL = $error->getMessage();
    echo 'Connection Failed: ' . $errorSQL;
    log_error($errorSQL,"ERROR DB CONNECT");
    exit();
}




/*
 * FUNCTIONS
 */
// TROCA DA DATA
function data_format($linear_date ){
    // Extrai os valores dos componentes da data
    $year = substr($linear_date, 0, 4);
    $month = substr($linear_date, 4, 2);
    $day = substr($linear_date, 6, 2);
    
    $format_date = $year."-".$month."-".$day;
    return $format_date;
}




/*
 * DIRETORIO
 */
$down_dir = $_SERVER['DOCUMENT_ROOT']."/CNPJ/DOWNLOADS/";




for ($xx = 0; $xx <= 9; $xx++) {
    $filename = $down_dir."K3241.K03200Y{$xx}.D30211.EMPRECSV";
    $file = fopen($filename, "r");

    // Lê o conteúdo do arquivo linha por linha
    while (!feof($file)) {
        $line = fgets($file);
        
        // RETIRANDO ASPAS
        $line = str_replace("\"", "", $line);
        
        // CRIANDO UM ARRAY COM OS DADOS
        $array = explode(';', $line);
        
        $cnpj = $array[0];
        $razao = $array[1];
        $natureza = $array[2];
        $estado = $array[3];
        $capital = $array[4];
        $porte = $array[5];
        $outro = $array[6];
        
        $del = array(",",".","R","$","S","U");
        $capital = str_replace($del,"",$capital);
        
        $sql = "INSERT INTO empresa VALUES ('','','{$cnpj}','{$razao}','{$natureza}','{$estado}','{$capital}','{$porte}','{$outro}')";
        $pdo->query($sql);

        // Insere os dados no MySQL
        //$sql = "INSERT INTO tabela (coluna1, coluna2, coluna3) VALUES ($line)";
        //mysqli_query($conn, $sql);



        $read++;
        if ($read == 30)
            exit();
    }
}